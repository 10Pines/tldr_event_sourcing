# TldrEventSourcing

This project is a simple, didactic example of how to do Event Sourcing with *very* minimal code. You could call it a punk-rock minimalistic take on it. It's supposed to be a Ticket system (although is more of a Post - Comment system) with a little blockchain magic sprinkled on.

Built for reference for the lightning talk @ BuzzConf 2019.

See https://tldr-event-sourcing.herokuapp.com/ for a live example

# How does it work

## The basic idea
This is a pure SQL solution where the events are merely records in an Event table. The bulk of the work is done in the `TldrEventSourcing.Event` module within the `emit_event` and the `apply_event` functions. The type of the event is denoted by:

* aggregate_type: an Elixir module name representing the type of the entity the event belongs to, and
* event_type: A symbol that denotes which kind of event it is.

So you'll have an event that creates an user with aggregate_type `Elixir.TldrEventSourcing.User`, event_type `user_created` and aggregate_id being the uuid of the user created.

Besides that, we keep track of data about the speaker, the timestamp of the event, a hash "braid" (more on that later) and of course the data of the event which is simply a json.

To "materialize the projection" of the event, a method is called synchronously, a method within the module that has the same name as the event_type. To do this, the Kernel.apply function is applied. Inside that function an SQL view is "materialized" (note that any view could be built in there, like for instance publishing to a key store, value... not only in a relational database). 

Commands are simply methods, like Ticket.create_ticket or Ticket.add_comment, that call the emit_event function. 

This very simplistic way of working allows for encapsulating the whole event mechanism behind the command methods and working with the "read model" in a way close enough to a simple ORM application while still having events as the main source of truth in the system.

## What about the blockchain

To have fun with event metadata this sample app shows how you could store in a blockchain (in this case the BSV blockchain) a way to "guarantee" (in a way....) that events (and basically the whole of your domain data) cannot be altered. How is it done? Each event has a parent_hash which is the hash of the previous event (except for the first one which is just null). We take the event data (except for the hash) and hash it and store the hash alongside the event. So you cannot alter a event without that having a ripple effect on the hashes along the line. This is not unlike git commits, which have a parent commit and a sha hash that is dependent of the commit changes. 

You can post to a BSV address arbitrary data in a transaction. This data is simple the latest hash.

By comparison, some blockchain apps do directly "event sourcing" by storing all events in the blockchain. 

## Comparison to a few Elixir Libraries

You can take a look at the https://github.com/slashdotdash/conduit sample app that uses the Elixir library Commanded for a much complex/sophisticated way of doing Event Sourcing while basically solving the same problem. See https://hexdocs.pm/chronik/Chronik.html for a different approach.

## A few comments on the implementation

Note that this is a a didactic example, not a productive app. That said, a few comments on the tradeoffs of this implementation

* You don't need to have all of your domain within Event Sourcing. In this case Credentials (i.e. user passwords) are handled completely outside of events.
* Commands are lacking validation. We should be validating that entities exist and user can operate with them. I did that with edit/delete comment but it's lacking in certain places. Probably Commands should be a little more complex than just a method call like this implementation (e.g. Ticket.add_comment) and have some generic validation.
* There are a few methods in there that aren't exposed in the web view to show how to deal with the problem of validation and locking crossing the lines between entities, particulary Ticket.assign_ticket. If you read long enough about how event sourcing is supposed to be done, this is kind of cheating in all sorts of ways, we are conflating the aggregate state (which is supposed to be doing the validation) with the projection (which is supposed to be the read model). See https://youtu.be/S3f6sAXa3-c?t=912 on a completely different way of solving this on a less simplistic event sourcing implementation.
* To replay events you can do `mix ReplayEvents`, that truncates the tables, reads the events by timestamp, and applies the events. That actually works, you can change the database structure and the functions that materialize event views and replay works just fine, but it's very naive. Probably we could and should version entities by version number both in the sql view and in the event and use that to sort the events to replay. That would allow for doing optimistic instead of pessimistic locking as well.
* Instead of materializing the events into SQL tables, we could instead be working with Plain Old Elixir Structs and have the functions be pure functions that operate on those structs. A nice property of doing this would be that we could easily ask for the state of an entity on any given date, which the current implementation cannot do.
* The hash chain (aka braid) ends up working like a global lock in the app. This might be highly undesirable and maybe a tree structure or a chain by aggregate be used. For simplicity, a simple chain was used.
* For simplicity Kernel.apply was used, but probably something a little more controlled should be used because Kernel.apply can call *any* function.

## Building/Running
You can start up a postgres database with docker-compose.yml or similar and then:

mix deps.get
mix test
mix ecto.create 
mix ecto.migrate
mix run priv/repo/seeds.exs
mix phx.server

### Building on Windows

The bcrypt dependency requires access to nmake.exe. You have to:
* install Visual Studio and include the C++ tools in the installation
* find the location of the vcvarsall.bat file. run "dir /s vcvarsall.bat" inside "C:\Program Files (x86)" or similar
* run `cmd /K "<path-to-vcvarsall.bat>" amd64`
* Then you can run mix deps.get

## To post latest hash to BSV blockchain

Install node & yarn, cd npm_blockchain_writer and do yarn install.

To be able to run this, you'll need to set the WALLET_PRIVATE_KEY and WALLET_PUBLIC_ADDRESS env variables. The address is actually optional and only used to create the hyperlink in the `/blockchain` html view.
