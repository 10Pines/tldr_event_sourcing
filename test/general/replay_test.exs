defmodule TldrEventSourcingTest.ReplayTest do
  use ExUnit.Case
  use TldrEventSourcing.RepoCase

  alias TldrEventSourcing.{SystemSpeaker, User, Ticket, Repo, Event, UserSpeaker}
  import Ecto.Query

  test "replay recreates everything" do
    ##GIVEN

    #initial setup
    root_id = SystemSpeaker.create_user("root")
    speaker = UserSpeaker.speaker(root_id)
    servant_id = UserSpeaker.create_user(speaker, "servant")

    ticket1 = Ticket.create_ticket(speaker, "Hacer MVP sistema de tickets")
    ticket2 = Ticket.create_ticket(speaker, "Vivir vida plena")
    ticket3 = Ticket.create_ticket(speaker, "Comer comida")
    ticket4 = Ticket.create_ticket(speaker, "Dormir")
    {:ok, nil} = Ticket.assign_ticket(speaker, ticket1, servant_id)
    {:ok, nil} = Ticket.assign_ticket(speaker, ticket2, servant_id)
    {:ok, nil} = Ticket.assign_ticket(speaker, ticket3, servant_id)
    Ticket.solve_ticket(UserSpeaker.speaker(servant_id), ticket1)
    {:ok, nil} = Ticket.assign_ticket(speaker, ticket4, servant_id)

    #truncate tables
    Repo.query("TRUNCATE users", [])
    Repo.query("TRUNCATE tickets", [])

    ##WHEN
    Event.replay_all

    ##THEN
    assert Repo.get(User, root_id).username == "root"
    assert Repo.get(Ticket, ticket1).is_solved
    assert Repo.get(Ticket, ticket4).assigned_to == servant_id
  end
end
