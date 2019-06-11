defmodule TldrEventSourcingWeb.SessionsController do
  use TldrEventSourcingWeb, :controller

  alias TldrEventSourcing.Accounts
  alias TldrEventSourcing.Accounts.Credentials

  def new(conn, _params) do
    render_new(conn)
  end

  def create(conn, %{"username" => username, "password" => password}) do
    case TldrEventSourcing.Accounts.Credentials.maybe_login(username, password) do
      {:ok, user} ->
        conn |>
          Plug.Conn.fetch_session |>
          TldrEventSourcingWeb.Auth.Guardian.Plug.sign_in(user) |>
          redirect(to: "/")
      {:error, error} ->
        render_new(conn, error)
    end
  end


  def logout(conn, _logout) do
    conn |>
      TldrEventSourcingWeb.Auth.Guardian.Plug.sign_out |>
      redirect(to: "/")
  end

  defp render_new(conn, error \\ nil) do
    conn
    |> put_layout(false)
    |> render("new.html", error: error)
  end
end
