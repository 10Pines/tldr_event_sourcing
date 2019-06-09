defmodule TldrEventSourcingWeb.Auth do
  def current_user(conn) do
    conn |> TldrEventSourcingWeb.Auth.Guardian.Plug.current_resource
  end

  def current_user_or_guest(conn) do
    current_user(conn) || guest()
  end

  def current_speaker(conn) do

    metadata = if conn do
      {a,b,c,d} = conn.remote_ip
      %{remote_ip: "#{a}.#{b}.#{c}.#{d}"}
    else
      %{}
    end

    TldrEventSourcing.UserSpeaker.speaker(current_user(conn).id, metadata)
  end

  defp guest() do
    %{id: nil, username: "guest"}
  end
end
