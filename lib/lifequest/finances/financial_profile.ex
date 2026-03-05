defmodule Lifequest.Finances.FinancialProfile do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "financial_profiles" do
    field :current_savings, :decimal
    field :current_debts, :decimal
    field :monthly_debt_payment, :decimal
    field :net_worth, :decimal
    field :employment_status, Ecto.Enum, values: [:cdi, :cdd, :freelance, :business_owner, :unemployed, :retired]

    belongs_to :user, Lifequest.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(financial_profile, attrs, user_scope) do
    financial_profile
    |> cast(attrs, [:current_savings, :current_debts, :monthly_debt_payment, :net_worth, :employment_status])
    |> validate_required([:current_savings, :current_debts, :monthly_debt_payment, :net_worth, :employment_status])
    |> put_change(:user_id, user_scope.user.id)
  end
end
