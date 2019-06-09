defmodule Mix.Tasks.UpdateTransactionStatus do
    use Mix.Task

    alias TldrEventSourcing.{HashBraid, Repo}

    require Logger

    @impl Mix.Task
    def run(args) do
        Application.ensure_all_started(:postgrex)
        Application.ensure_all_started(:ecto)
        Application.ensure_all_started(:ecto_sql)
        Application.ensure_all_started(:hackney)

        Repo.start_link

        TldrEventSourcing.BlockchainTransaction.update_transaction_statuses
    end
  end
