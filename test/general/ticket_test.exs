defmodule TldrEventSourcingTest.TicketTest do
  use ExUnit.Case
  use TldrEventSourcing.RepoCase

  alias TldrEventSourcing.{SystemSpeaker, User, Ticket, Repo, Event, UserSpeaker, Ticket.Comment}
  import Ecto.Query

  test "create_ticket" do
    user_id = SystemSpeaker.create_user("root")
    speaker = UserSpeaker.speaker(user_id)

    ticket_id = Ticket.create_ticket(speaker, "Hacer MVP sistema de tickets", "el cuerpo")
    inserted = Repo.get_by(Event, aggregate_id: ticket_id)

    ticket = Repo.get(Ticket, ticket_id) |> Repo.preload(:author)
    assert ticket.title ==  "Hacer MVP sistema de tickets"
    assert ticket.is_solved == false
    assert ticket.assigned_to == nil
    assert ticket.author_id == user_id
    assert ticket.author.username == "root"
    assert ticket.body == "el cuerpo"
    assert ticket.timestamp == inserted.timestamp


    assert inserted.speaker_type == "Elixir.TldrEventSourcing.UserSpeaker"
    assert inserted.speaker_id == user_id
    assert inserted.aggregate_type == "Elixir.TldrEventSourcing.Ticket"
    assert inserted.event_type == "ticket_created"
    assert inserted.data == %{"title" => "Hacer MVP sistema de tickets", "body" => "el cuerpo"}

  end

  test "assign_ticket" do
    root_id = SystemSpeaker.create_user("root")
    speaker = UserSpeaker.speaker(root_id)
    servant_id = UserSpeaker.create_user(speaker, "servant")

    ticket_id = Ticket.create_ticket(speaker, "Hacer MVP sistema de tickets")
    Ticket.assign_ticket(speaker, ticket_id, servant_id)

    ticket = Repo.get(Ticket, ticket_id)
    assert ticket.title ==  "Hacer MVP sistema de tickets"
    assert ticket.is_solved == false
    assert ticket.assigned_to == servant_id
  end

  test "solve_ticket" do
    root_id = SystemSpeaker.create_user("root")
    speaker = UserSpeaker.speaker(root_id)
    servant_id = UserSpeaker.create_user(speaker, "servant")

    ticket_id = Ticket.create_ticket(speaker, "Hacer MVP sistema de tickets")
    Ticket.assign_ticket(speaker, ticket_id, servant_id)
    Ticket.solve_ticket(UserSpeaker.speaker(servant_id), ticket_id)

    ticket = Repo.get(Ticket, ticket_id)
    assert ticket.title ==  "Hacer MVP sistema de tickets"
    assert ticket.is_solved == true
    assert ticket.assigned_to == servant_id
  end

  test "user must not have more than 3 assigned tickets" do
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

    {:error, "too many tickets"} = Ticket.assign_ticket(speaker, ticket4, servant_id)

    ticket = Repo.get(Ticket, ticket4)
    assert ticket.assigned_to == nil

    query = from e in Event, where: e.event_type == "ticket_assigned"
    Repo.aggregate(query, :count, :aggregate_id) == 3
  end

  test "user must not have more than 3 assigned tickets, but solved do not count" do
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

    ticket = Repo.get(Ticket, ticket4)
    assert ticket.assigned_to == servant_id
  end


  test "add_comment adds the comment" do
    root_id = SystemSpeaker.create_user("root")
    speaker = UserSpeaker.speaker(root_id)
    servant_id = UserSpeaker.create_user(speaker, "servant")

    ticket = Ticket.create_ticket(speaker, "Hacer MVP sistema de tickets")
    Ticket.add_comment(speaker, ticket, "a comment")
    inserted = Repo.get_by(Event, aggregate_id: ticket, event_type: "comment_added")

    [comment] = Repo.all(Comment) |> Repo.preload(:ticket)
    assert comment.text == "a comment"
    assert comment.timestamp == inserted.timestamp
    assert comment.author_id == root_id
    assert comment.ticket_id == ticket
    assert comment.ticket.title == "Hacer MVP sistema de tickets"
  end

  test "edit_comment edits the comment" do
    root_id = SystemSpeaker.create_user("root")
    speaker = UserSpeaker.speaker(root_id)
    servant_id = UserSpeaker.create_user(speaker, "servant")

    ticket = Ticket.create_ticket(speaker, "Hacer MVP sistema de tickets")
    comment_id = Ticket.add_comment(speaker, ticket, "a comment")
    Ticket.add_comment(speaker, ticket, "a different comment")
    Ticket.edit_comment(speaker, ticket, comment_id, "now it says something else")
    inserted = Repo.get_by(Event, aggregate_id: ticket, event_type: "comment_edited")

    comment = Repo.get(Comment, comment_id)
    assert comment.text == "now it says something else"
  end

  test "edit_comment fails if the comment doesn't belong to the ticket" do
    root_id = SystemSpeaker.create_user("root")
    speaker = UserSpeaker.speaker(root_id)
    servant_id = UserSpeaker.create_user(speaker, "servant")

    ticket = Ticket.create_ticket(speaker, "Hacer MVP sistema de tickets")
    another_ticket = Ticket.create_ticket(speaker, "Another ticket")

    comment_id = Ticket.add_comment(speaker, ticket, "a comment")
    Ticket.add_comment(speaker, ticket, "a different comment")
    {:error, "no comment found"} = Ticket.edit_comment(speaker, another_ticket, comment_id, "now it says something else")
    nil = Repo.get_by(Event, aggregate_id: ticket, event_type: "comment_edited")
    comment = Repo.get(Comment, comment_id)
    assert comment.text == "a comment"
  end

  test "edit_comment fails if the comment doesn't belong to the speaker" do
    root_id = SystemSpeaker.create_user("root")
    speaker = UserSpeaker.speaker(root_id)
    servant_id = UserSpeaker.create_user(speaker, "servant")

    ticket = Ticket.create_ticket(speaker, "Hacer MVP sistema de tickets")

    comment_id = Ticket.add_comment(speaker, ticket, "a comment")
    {:error, "no comment found"} = Ticket.edit_comment(UserSpeaker.speaker(servant_id), ticket, comment_id, "now it says something else")
  end
end
