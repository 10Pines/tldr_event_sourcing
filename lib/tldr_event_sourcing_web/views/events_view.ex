defmodule TldrEventSourcingWeb.EventsView do
  use TldrEventSourcingWeb, :view
  alias TldrEventSourcingWeb.EventsView
  require Integer
  require String

  def remove_namespace(str) do
    String.replace(str, "Elixir.TldrEventSourcing.", "")
  end

  def class_for_event(event, idx) do
    if event.aggregate_type == "Elixir.TldrEventSourcing.BlockchainTransaction" do
      "blockchain"
    else
      if Integer.is_even(idx), do: "even", else: "odd"
    end
  end

  def truncate_uuid(uuid) do
    truncate_any uuid, 6
  end

  def truncate_hash(hash) do
    truncate_any hash, 16
  end

  def truncate_any(string, length) do
    {:safe, "<span title=\"#{string}\"> #{String.slice(string, 0..length)}...</span>"}
  end
end
