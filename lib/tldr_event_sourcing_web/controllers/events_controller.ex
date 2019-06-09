defmodule TldrEventSourcingWeb.EventsController do
  use TldrEventSourcingWeb, :controller
  alias TldrEventSourcing.{Repo, Event}
  import Ecto.Query
  require Logger

  def index(conn, params) do
    speaker_id = Map.get(params, "speaker_id")
    aggregate_id = Map.get(params, "aggregate_id")
    aggregate_type = Map.get(params, "aggregate_type")

    events = build_filter(speaker_id, aggregate_id) |> order_by([asc: :timestamp]) |> Repo.all()
    render(conn, "index.html", events: events, speaker_id: speaker_id, aggregate_id: aggregate_id, aggregate_type: aggregate_type)
  end

  def index_json(conn, _params) do
    events = Event |> order_by([asc: :timestamp]) |> Repo.all()
    json(conn, events)
  end

  defp build_filter(speaker_id, aggregate_id) do
    query = Event

    query = case speaker_id do
      "SYSTEM" -> query |> where(speaker_type: "SYSTEM")
      nil -> query
      speaker_id -> query |> where(speaker_id: ^speaker_id)
    end

    query = if aggregate_id do
      query |> where(aggregate_id: ^aggregate_id)
    else
      query
    end

    query
  end

end
