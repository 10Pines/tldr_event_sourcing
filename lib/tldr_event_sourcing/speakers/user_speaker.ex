defmodule TldrEventSourcing.UserSpeaker do

  def create_user(speaker, username) do
    TldrEventSourcing.User.create_user(speaker, username)
  end

  def speaker(user_id, metadata \\ %{}) do
    %TldrEventSourcing.Speaker{
      speaker_type: __MODULE__,
      speaker_id: user_id,
      speaker_metadata: metadata
    }
  end
end
