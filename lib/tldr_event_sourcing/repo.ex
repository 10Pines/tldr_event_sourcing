defmodule TldrEventSourcing.Repo do
  use Ecto.Repo,
    otp_app: :tldr_event_sourcing,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query, only: [from: 2]

  def lock_entity(module, entity_id) do
    query = from a in module,
        where: a.id == ^entity_id,
        lock: "FOR UPDATE"

    user = all(query) |> List.first
  end

  def get_first_with_lock(module) do
    query = from a in module,
        lock: "FOR UPDATE"

    user = all(query) |> List.first
  end
end
