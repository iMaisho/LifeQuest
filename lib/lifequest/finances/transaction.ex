defmodule Lifequest.Finances.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :label, :string
    field :direction, Ecto.Enum, values: [:income, :expense]

    field :income_type, Ecto.Enum,
      values: [
        :salary,
        :freelance,
        :rental,
        :bonus,
        :pension,
        :government_aid,
        :investment,
        :other
      ]

    field :expense_type, Ecto.Enum, values: [:essential, :pleasure, :savings, :extra, :other]
    field :amount, :decimal
    field :date, :date
    field :is_recurring, :boolean, default: false
    field :is_active, :boolean, default: true
    belongs_to :user, Lifequest.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(transaction, attrs, scope) do
    transaction
    |> cast(attrs, [
      :label,
      :direction,
      :income_type,
      :expense_type,
      :amount,
      :date,
      :is_recurring,
      :is_active
    ])
    |> validate_required([:label, :direction, :amount, :date])
    |> validate_type_by_direction()
    |> put_change(:user_id, scope.user.id)
  end

  defp validate_type_by_direction(changeset) do
    case get_field(changeset, :direction) do
      :income ->
        changeset
        |> validate_required([:income_type])
        |> put_change(:expense_type, nil)

      :expense ->
        changeset
        |> validate_required([:expense_type])
        |> put_change(:income_type, nil)

      _ ->
        changeset
    end
  end
end
