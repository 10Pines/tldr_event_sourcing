defmodule TldrEventSourcing.Repo.Migrations.CreateBlockchainTransaction do
  use Ecto.Migration

  def change do
    create table(:blockchain_transaction, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :published_hash, :string
      add :transaction_id, :string
      add :status, :string
    end
  end
end
