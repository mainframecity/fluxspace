defmodule Fluxspace.Repo.Migrations.CreateAccountsTable do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :username, :text, null: false
      add :password, :text, null: false
      add :last_logged_in, :utc_datetime

      timestamps()
    end

    create index(:accounts, [:username], unique: true)
  end
end
