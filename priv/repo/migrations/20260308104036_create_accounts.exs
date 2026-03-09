defmodule Lifequest.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :label, :string
      add :type, :string
      add :balance, :decimal, precision: 18, scale: 2
      add :interest_rate, :decimal, precision: 6, scale: 3
      add :is_active, :boolean, default: false, null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:accounts, [:user_id])
  end
end
