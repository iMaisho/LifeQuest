defmodule Lifequest.Repo.Migrations.CreateFinancialProfiles do
  use Ecto.Migration

  def change do
    create table(:financial_profiles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :current_savings, :decimal, precision: 18, scale: 2
      add :current_debts, :decimal, precision: 18, scale: 2
      add :monthly_debt_payment, :decimal, precision: 18, scale: 2
      add :net_worth, :decimal, precision: 18, scale: 2
      add :employment_status, :string
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:financial_profiles, [:user_id])
  end
end
