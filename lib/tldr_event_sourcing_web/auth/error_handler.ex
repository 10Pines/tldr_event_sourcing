defmodule TldrEventSourcingWeb.Auth.ErrorHandler do

  import Plug.Conn
  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_resp_header("location", "/sessions/new")
    |> send_resp(302, "")
  end
end
