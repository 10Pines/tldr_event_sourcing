defmodule TldrEventSourcingWeb.TicketsView do
  use TldrEventSourcingWeb, :view
  alias TldrEventSourcingWeb.TicketsView

  def sorted_comments(ticket) do
    Enum.sort_by(ticket.comments, fn c -> DateTime.to_unix(c.timestamp) end)
  end
end
