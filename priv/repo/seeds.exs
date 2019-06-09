alias TldrEventSourcing.{SystemSpeaker, User, Ticket, Repo, Event, UserSpeaker, Accounts.Credentials}
import Ecto.Query

root_id = SystemSpeaker.create_user("root")
speaker = UserSpeaker.speaker(root_id)
servant_id = UserSpeaker.create_user(speaker, "servant")
explainer_id = UserSpeaker.create_user(speaker, "explainer")
servant_speaker =  UserSpeaker.speaker(servant_id)
explainer_speaker =  UserSpeaker.speaker(explainer_id)
Credentials.create_credential(servant_id, "password1")
ticket_id = Ticket.create_ticket(speaker, "Build Ticket System MVP", "Why? Because I can")
ticket2 = Ticket.create_ticket(speaker, "Live a fulfilling life")
ticket3 = Ticket.create_ticket(speaker, "Eat food")
ticket4 = Ticket.create_ticket(speaker, "Sleep tight")
Ticket.add_comment(servant_speaker, ticket_id, "Really? There is no other option")
Ticket.add_comment(speaker, ticket_id, "Yes, really!")

ticket_explanation = Ticket.create_ticket(explainer_speaker, "Explain Event Sourcing very quickly")
Ticket.add_comment(explainer_speaker, ticket_explanation, "Event Sourcing is derived from Command Query Responsability Segregation")
Ticket.add_comment(explainer_speaker, ticket_explanation, "Instead of a single read/write model, we have two models:")
Ticket.add_comment(explainer_speaker, ticket_explanation, "A read model that answers Queries and a write model that answers Commands")
Ticket.add_comment(explainer_speaker, ticket_explanation, "In this sample app, we have a SQL database of User, Tickets and Comments")
Ticket.add_comment(explainer_speaker, ticket_explanation, "It's fairly boring, but that's just the read model")
Ticket.add_comment(explainer_speaker, ticket_explanation, "The actual source of truth is the write model, which is an immutable, append-only, list of events")
Ticket.add_comment(explainer_speaker, ticket_explanation, "The User, Ticket, and Comment tables work like \"materialized views\" of a reduce-like operation on this list")

ticket_gains = Ticket.create_ticket(explainer_speaker, "Tell me more about what do I gain doing this")
Ticket.add_comment(explainer_speaker, ticket_gains, "Can denormalize data, have more than one projection or view of the data")
Ticket.add_comment(explainer_speaker, ticket_gains, "You can have the read(s) model(s) be updated asynchronously if needed")
Ticket.add_comment(explainer_speaker, ticket_gains, "You can rewind in time and get the state of an entity on a given point of time, for any entity")
Ticket.add_comment(explainer_speaker, ticket_gains, "The history of the state of the app is no longer opaque")
Ticket.add_comment(explainer_speaker, ticket_gains, "You can modify your projecting functions and easily reapply")
Ticket.add_comment(explainer_speaker, ticket_gains, "You've reified your events. You've got Event Metadata for everything")

ticket_metadata = Ticket.create_ticket(explainer_speaker, "Tell me more about Event Metadata")
Ticket.add_comment(explainer_speaker, ticket_metadata, "You've reified events, now all events have their metadata")
Ticket.add_comment(explainer_speaker, ticket_metadata, "An event might have it's own data, e.g. comment_added has the text of the comment")
Ticket.add_comment(explainer_speaker, ticket_metadata, "But all events have metadata that's universal: Who said it, when, the ip, timestamp, etc.")
Ticket.add_comment(explainer_speaker, ticket_metadata, "In this sample app, as an example of the power of metadata, all events have a hash and a parent hash")
Ticket.add_comment(explainer_speaker, ticket_metadata, "(Something not unlike git commits)")
Ticket.add_comment(explainer_speaker, ticket_metadata, "The hash can also be published to the BSV blockchain, to guarantee immutability of your data")







