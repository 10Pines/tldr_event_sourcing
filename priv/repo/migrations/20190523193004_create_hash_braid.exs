defmodule TldrEventSourcing.Repo.Migrations.CreateHashBraid do
  use Ecto.Migration

  def change do
    create table(:hash_braid) do
      add :latest_event, :integer
      add :latest_hash, :string
      timestamps()
    end
  end
end
