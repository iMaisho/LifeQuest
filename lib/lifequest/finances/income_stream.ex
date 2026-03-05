defmodule Lifequest.Finances.IncomeStream do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "income_streams" do
    field :label, :string
    field :type, Ecto.Enum, values: [:salary, :freelance, :rental, :bonus, :pension, :government_aid, :investment, :other]
    field :amount, :decimal
    field :frequency, Ecto.Enum, values: [:weekly, :monthly, :quarterly, :yearly, :one_time]
    field :start_date, :date
    field :end_date, :date
    field :is_active, :boolean, default: false

    belongs_to :user, Lifequest.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(income_stream, attrs, user_scope) do
    income_stream
    |> cast(attrs, [:label, :type, :amount, :frequency, :start_date, :end_date, :is_active])
    |> validate_required([:label, :type, :amount, :frequency, :start_date, :end_date, :is_active])
    |> put_change(:user_id, user_scope.user.id)
  end
end
