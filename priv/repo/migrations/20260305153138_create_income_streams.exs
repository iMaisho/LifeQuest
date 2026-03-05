defmodule Lifequest.Repo.Migrations.CreateIncomeStreams do
  use Ecto.Migration

  def change do
    create table(:income_streams, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :label, :string
      add :type, :string
      add :amount, :decimal, precision: 18, scale: 2
      add :frequency, :string
      add :start_date, :date
      add :end_date, :date
      add :is_active, :boolean, default: false, null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:income_streams, [:user_id])
  end
end
