defmodule Lifequest.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :label, :string
      add :direction, :string
      add :income_type, :string
      add :expense_type, :string
      add :amount, :decimal, precision: 18, scale: 2
      add :date, :date
      add :is_recurring, :boolean, default: false, null: false
      add :is_active, :boolean, default: true, null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:user_id])
  end
end
