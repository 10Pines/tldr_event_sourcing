defmodule TldrEventSourcing.HashBraid do
  use Ecto.Schema
  alias TldrEventSourcing.{Repo, Event}
  import Ecto.Query, only: [from: 2]
  require Logger
  import Ecto.Changeset

  schema "hash_braid" do
    field :latest_event, :integer
    field :latest_hash, :string
    timestamps()
  end

  def get_latest_hash_and_lock! do
    Repo.get_first_with_lock(__MODULE__)
  end

  def update_hash_braid!(event, hash_braid) do
    if hash_braid do
      change = change(hash_braid, %{latest_event: event.id, latest_hash: event.hash})
      Repo.update!(change)
    else
      Repo.insert!(%__MODULE__{latest_event: event.id, latest_hash: event.hash})
    end
  end

end
