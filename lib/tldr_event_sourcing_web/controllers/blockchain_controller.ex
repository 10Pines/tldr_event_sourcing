defmodule TldrEventSourcingWeb.BlockchainController do
  use TldrEventSourcingWeb, :controller
  alias TldrEventSourcing.{Repo}
  import Ecto.Query
  require Logger

  def index(conn, _params) do
    bts = Repo.all(TldrEventSourcing.BlockchainTransaction)
    transactions_with_index = Enum.zip(bts, 0..length(bts))
    render(conn, "index.html", transactions_with_index: transactions_with_index, address: TldrEventSourcing.BlockchainTransaction.address)
  end

  def post_transaction(conn, _params) do
    TldrEventSourcing.BlockchainTransaction.publish_hash!
    index(conn, %{})
  end

  def update_transaction_status(conn, _params) do
    TldrEventSourcing.BlockchainTransaction.update_transaction_statuses
    index(conn, %{})
  end

end
