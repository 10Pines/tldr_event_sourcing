defmodule TldrEventSourcing.Repo.Migrations.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:credentials) do
      add :user_id, :uuid
      add :encrypted_password, :string

      timestamps()
    end

  end
end
