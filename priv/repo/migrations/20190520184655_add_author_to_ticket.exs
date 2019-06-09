defmodule TldrEventSourcing.Repo.Migrations.AddAuthorToTicket do
  use Ecto.Migration

  def change do
    alter table(:tickets) do
      add :author_id, :uuid
    end
  end
end
