defmodule TldrEventSourcingWeb.TablesController do
  use TldrEventSourcingWeb, :controller
  alias TldrEventSourcing.{Repo, Ticket, User, Ticket.Comment}
  alias TldrEventSourcing.Accounts.Credentials
  import Ecto.Query
  require Logger

  def index(conn, params) do
    tickets = Repo.all(Ticket)
    users = Repo.all(User)
    credentials = Repo.all(Credentials)
    comments = Repo.all(Comment)

    render(conn, "index.html", users: users, tickets: tickets, comments: comments, credentials: credentials)
  end
end
