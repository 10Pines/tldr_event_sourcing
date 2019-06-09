defmodule TldrEventSourcing.SystemSpeaker do

  def create_user(username) do
    TldrEventSourcing.User.create_user(system_speaker(), username)
  end

  def system_speaker() do
    %TldrEventSourcing.Speaker{
      speaker_type: "SYSTEM"
    }
  end
end
