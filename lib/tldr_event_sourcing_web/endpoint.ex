defmodule TldrEventSourcingWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :tldr_event_sourcing

  socket "/socket", TldrEventSourcingWeb.UserSocket,
    websocket: [timeout: 45_000],
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: "priv/static",
    gzip: false,
    only: ~w(css fonts images app.js *.app.js favicon.ico robots.txt assets) ++ Enum.map(0..100, fn i -> "#{i}.app.js" end)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_tldr_event_sourcing_key",
    signing_salt: "E29QZLiT"

  plug TldrEventSourcingWeb.Router
end
