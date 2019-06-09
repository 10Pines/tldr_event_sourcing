defmodule TldrEventSourcing.User do
  use TldrEventSourcing.Schema

  schema "users" do
    field :username, :string
  end

  def get_user! id do
    TldrEventSourcing.Repo.get!(__MODULE__, id)
  end

  def create_user(speaker, username) do
    id = Ecto.UUID.generate
    TldrEventSourcing.Event.emit_event(speaker, __MODULE__, :user_created, id, %{username: username})
    id
  end

  def user_created(%{username: username}, %{aggregate_id: user_id}) do
    u = %TldrEventSourcing.User{username: username, id: user_id}
    TldrEventSourcing.Repo.insert(u)
  end


end
