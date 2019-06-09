# TldrEventSourcing


## Building/Running
Levantate la base de docker-compose.yml (o similar y reconfigurá)

mix deps.get
mix test
mix ecto.create 
mix ecto.migrate
mix run priv/repo/seeds.exs
mix phx.server

cheat: mix ecto.drop && mix ecto.create && mix ecto.migrate && mix run priv/repo/seeds.exs

### Building on Windows

The bcrypt dependency requires access to nmake.exe. You have to:
* install Visual Studio and include the C++ tools in the installation
* find the location of the vcvarsall.bat file. run "dir /s vcvarsall.bat" inside "C:\Program Files (x86)" or similar
* run `cmd /K "<path-to-vcvarsall.bat>" amd64`
* Then you can run mix deps.get

## Replay de eventos

Para borrar las vistas de las entidades y hacer replay de eventos, por ejemplo si modificamos la estructura de la vistas y queremos reaplicar nuestras funciones, podemos correr `mix ReplayEvents`

## To post latest hash to BSV blockchain

Install node & yarn, cd npm_blockchain_writer and do yarn install.

To be able to run this, you'll need to set the WALLET_PRIVATE_KEY and WALLET_PUBLIC_ADDRESS env variables. The address is actually optional and only used to create the hyperlink in the `/blockchain` html view.

## A few comments

* Auth/Guest mode is half baked. 
* Commands are lacking validation. We should be validating that entities exist and user can operate with them. I did that with edit/delete comment but it's lacking in certain places, and maybe it's not very good in general. Possibly Commands should be a little more complex than just a method call like this implementation (e.g. Ticket.add_comment) and have some generic validation.