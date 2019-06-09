defmodule Mix.Tasks.PublishHash do
    use Mix.Task

    alias TldrEventSourcing.{HashBraid, Repo}

    require Logger

    @impl Mix.Task
    def run(args) do
        Application.ensure_all_started(:postgrex)
        Application.ensure_all_started(:ecto)
        Application.ensure_all_started(:ecto_sql)

        Repo.start_link

        TldrEventSourcing.BlockchainTransaction.publish_hash!
    end
  end
