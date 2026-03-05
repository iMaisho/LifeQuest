defmodule Lifequest.Finances.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "expenses" do
    field :name, :string
    field :type, Ecto.Enum, values: [:essential, :pleasure, :savings, :extra]
    field :amount, :decimal
    field :frequency, Ecto.Enum, values: [:weekly, :monthly, :quarterly, :yearly, :one_time]

    belongs_to :user, Lifequest.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs, user_scope) do
    expense
    |> cast(attrs, [:name, :type, :amount, :frequency])
    |> validate_required([:name, :type, :amount, :frequency])
    |> put_change(:user_id, user_scope.user.id)
  end
end
