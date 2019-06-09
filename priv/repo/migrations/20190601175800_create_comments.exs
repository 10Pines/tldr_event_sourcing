defmodule TldrEventSourcing.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :text, :string
      add :author_id, :uuid
      add :ticket_id, :uuid
      add :timestamp, :utc_datetime_usec
    end
  end
end
