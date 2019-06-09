defmodule TldrEventSourcing.Event do
  use Ecto.Schema
  alias TldrEventSourcing.{Repo, Event, HashBraid}
  import Ecto.Query, only: [from: 2]
  require Logger

  @derive {Jason.Encoder, only: [
    :speaker_id, :speaker_type, :speaker_metadata, :aggregate_id, :aggregate_type,
    :event_type, :parent_hash, :hash, :data, :timestamp
  ]}

  schema "events" do
    field :speaker_id, :binary_id
    field :speaker_type, :string
    field :speaker_metadata, :map
    field :aggregate_id, :binary_id
    field :aggregate_type, :string
    field :event_type, :string
    field :parent_hash, :string
    field :hash, :string
    field :data, :map
    field :timestamp, :utc_datetime_usec
  end

  def emit_event(speaker, module, event, aggregate_id, event_data) do
    event = %Event{
      speaker_type: to_string(speaker.speaker_type),
      speaker_id: speaker.speaker_id,
      speaker_metadata: speaker.speaker_metadata,
      aggregate_id: aggregate_id,
      aggregate_type: to_string(module),
      event_type: to_string(event),
      timestamp: current_timestamp,
      data: event_data
    }
    {event, hash_braid} = set_hashes_for_event(event)
    {:ok, inserted} = Repo.insert(event)
    apply_event(Repo.get(Event, inserted.id))
    HashBraid.update_hash_braid!(inserted, hash_braid)
    nil
  end

  def apply_event(event) do
    module = String.to_existing_atom(event.aggregate_type)
    method = String.to_existing_atom(event.event_type)
    metadata = get_metadata(event)
    data = get_data(event)

    apply(module, method, [data, metadata])

    nil #you won't care about the return value
  end

  def replay_all do
    query = from e in Event, order_by: e.timestamp
    all = Repo.all(query)
    Enum.each(all, fn e -> apply_event(e) end)
  end

  defp get_metadata(event) do
    %{aggregate_id: event.aggregate_id,
      speaker_id: event.speaker_id,
      speaker_type: event.speaker_type,
      speaker_metadata: event.speaker_metadata,
      timestamp: event.timestamp
    }
  end

  defp get_data(event) do
    for {key, val} <- event.data, into: %{}, do: {String.to_atom(key), val}
  end

  defp set_hashes_for_event(event) do
    parent_hash_braid = HashBraid.get_latest_hash_and_lock!
    event = if parent_hash_braid do
      %{event | parent_hash: parent_hash_braid.latest_hash}
    else
      event
    end
    {%{event | hash: get_event_hash(event)}, parent_hash_braid}
  end

  defp get_event_hash(event) do
    {:ok, json} = Jason.encode(event)
    Logger.info  "event json: #{json}"

    :crypto.hash(:sha256, json) |> Base.encode16 |> String.downcase
  end

  defp current_timestamp do
    DateTime.utc_now
  end
end
