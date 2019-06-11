defmodule TldrEventSourcingWeb.TicketsController do
  use TldrEventSourcingWeb, :controller

  plug Guardian.Plug.EnsureAuthenticated when action in [:create, :add_comment, :edit_comment, :delete_comment]

  alias TldrEventSourcing.{Repo, Ticket}
  require Logger

  def index(conn, _params) do
    tickets = Repo.all(Ticket) |> Repo.preload(:author)
    render(conn, "index.html", tickets: tickets)
  end

  def show(conn, %{"id" => id}) do
    ticket = Repo.get!(Ticket, id) |> Repo.preload(:author) |> Repo.preload(comments: :author)
    render(conn, "show.html", ticket: ticket)
  end

  def create(conn, %{"title" => title}) do
    speaker = TldrEventSourcingWeb.Auth.current_speaker(conn)
    Ticket.create_ticket(speaker, title)
    index(conn, %{})
  end

  def add_comment(conn, %{"text" => text, "ticket_id" => ticket_id}) do
    speaker = TldrEventSourcingWeb.Auth.current_speaker(conn)
    Ticket.add_comment(speaker, ticket_id, text)
    show(conn, %{"id" => ticket_id})
  end

  def edit_comment(conn, %{"text" => text, "ticket_id" => ticket_id, "comment_id" => comment_id}) do
    speaker = TldrEventSourcingWeb.Auth.current_speaker(conn)
    Ticket.edit_comment(speaker, ticket_id, comment_id, text)
    show(conn, %{"id" => ticket_id})
  end

  def delete_comment(conn, %{"ticket_id" => ticket_id, "comment_id" => comment_id}) do
    speaker = TldrEventSourcingWeb.Auth.current_speaker(conn)
    Ticket.delete_comment(speaker, ticket_id, comment_id)
    show(conn, %{"id" => ticket_id})
  end
end
