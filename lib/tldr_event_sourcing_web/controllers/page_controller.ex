defmodule TldrEventSourcingWeb.PageController do
  use TldrEventSourcingWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
