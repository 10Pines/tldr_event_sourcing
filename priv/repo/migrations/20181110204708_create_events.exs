defmodule TldrEventSourcing.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :speaker_id, :uuid
      add :speaker_type, :string
      add :speaker_metadata, :map
      add :aggregate_id, :uuid
      add :aggregate_type, :string
      add :event_type, :string
      add :parent_hash, :string
      add :hash, :string
      add :data, :map
      add :timestamp, :utc_datetime_usec
    end
  end
end
