defmodule TldrEventSourcing.BlockchainTransaction do
    use TldrEventSourcing.Schema

    alias TldrEventSourcing.{Event, HashBraid, Repo, BlockchainTransaction}
    require Logger
    import Ecto.Query, only: [from: 2]
    import Ecto.Changeset


    schema "blockchain_transaction" do
        field :published_hash, :string
        field :transaction_id, :string
        field :status, :string
    end

    def address do
        Application.get_env(:tldr_event_sourcing, :hash_braid)[:address]
    end

    def publish_hash! do
        hash_braid = HashBraid.get_latest_hash_and_lock!

        hash = hash_braid.latest_hash
        private_key = Application.get_env(:tldr_event_sourcing, :hash_braid)[:wallet_private_key]

        %{"transactionId" => transaction_id} = perform_transaction(hash, private_key)

        id = Ecto.UUID.generate
        Event.emit_event(TldrEventSourcing.SystemSpeaker.system_speaker(), __MODULE__,
            :transaction_published,
            id,
            %{hash: hash, transaction_id: transaction_id})
        transaction_id
    end

    def update_transaction_statuses do
        query = from t in BlockchainTransaction, where: t.status == "UNKNOWN"
        blockchain_transactions = Repo.all(query)
        Enum.each(blockchain_transactions, fn t -> update_transaction_status_for(t) end)
    end

    def update_transaction_status_for(blockchain_transaction) do
        response = HTTPoison.get!("https://api.whatsonchain.com/v1/bsv/main/tx/hash/#{blockchain_transaction.transaction_id}")
        if response.status_code == 200 do
            req = Jason.decode!(response.body)
            Event.emit_event(TldrEventSourcing.SystemSpeaker.system_speaker(), __MODULE__,
                            :transaction_status_updated,
                            blockchain_transaction.id,
                            %{whatsonchain_response: req})
        else
            Logger.info("got status #{response.status_code} for tx #{blockchain_transaction.id}")
        end
    end

    #Events
    def transaction_status_updated(%{whatsonchain_response: response}, %{aggregate_id: id}) do
        status = if response["confirmations"] == 0, do: "UNCONFIRMED", else: "CONFIRMED"
        tx = Repo.get_by(__MODULE__, id: id)
        change(tx, status: status) |> Repo.update
    end

    def transaction_published(%{hash: hash, transaction_id: transaction_id},%{aggregate_id: id}) do
        u = %BlockchainTransaction{id: id, published_hash: hash, transaction_id: transaction_id, status: "UNKNOWN"}
        Repo.insert(u)
    end

    defp perform_transaction(hash, private_key) do
        node_script = Path.join([File.cwd!, "npm_blockchain_writer/index.js"])
        {output, 0} = System.cmd("node", [node_script, "--hash", hash, "--private-key", private_key])
        Logger.info(output)
        Jason.decode!(output)
    end

  end
