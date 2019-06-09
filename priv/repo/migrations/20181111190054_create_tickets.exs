defmodule TldrEventSourcing.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :body, :string
      add :assigned_to, :uuid
      add :is_solved, :boolean
      add :timestamp, :utc_datetime_usec
    end
  end
end
