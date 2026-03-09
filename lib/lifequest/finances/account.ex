defmodule Lifequest.Finances.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :label, :string

    field :type, Ecto.Enum,
      values: [:checking, :savings, :investment, :real_estate, :retirement, :crypto]

    field :balance, :decimal
    field :interest_rate, :decimal
    field :is_active, :boolean, default: false

    belongs_to :user, Lifequest.Accounts.User
    has_many :transactions, Lifequest.Finances.Transaction

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs, user_scope) do
    account
    |> cast(attrs, [:label, :type, :balance, :interest_rate, :is_active])
    |> validate_required([:label, :type, :balance, :interest_rate, :is_active])
    |> put_change(:user_id, user_scope.user.id)
  end
end
