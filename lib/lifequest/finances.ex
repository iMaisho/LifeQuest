defmodule Lifequest.Finances do
  @moduledoc """
  The Finances context.
  """

  import Ecto.Query, warn: false

  alias Lifequest.Accounts.Scope
  alias Lifequest.Finances.Account
  alias Lifequest.Finances.FinancialProfile
  alias Lifequest.Finances.Transaction
  alias Lifequest.Repo

  @doc """
  Subscribes to scoped notifications about any financial_profile changes.

  The broadcasted messages match the pattern:

    * {:created, %FinancialProfile{}}
    * {:updated, %FinancialProfile{}}
    * {:deleted, %FinancialProfile{}}

  """
  def subscribe_financial_profiles(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Lifequest.PubSub, "user:#{key}:financial_profiles")
  end

  defp broadcast_financial_profile(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Lifequest.PubSub, "user:#{key}:financial_profiles", message)
  end

  @doc """
  Returns the list of financial_profiles.

  ## Examples

      iex> list_financial_profiles(scope)
      [%FinancialProfile{}, ...]

  """
  def list_financial_profiles(%Scope{} = scope) do
    Repo.all_by(FinancialProfile, user_id: scope.user.id)
  end

  @doc """
  Gets a single financial_profile.

  Raises `Ecto.NoResultsError` if the Financial profile does not exist.

  ## Examples

      iex> get_financial_profile!(scope, 123)
      %FinancialProfile{}

      iex> get_financial_profile!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_financial_profile!(%Scope{} = scope, id) do
    Repo.get_by!(FinancialProfile, id: id, user_id: scope.user.id)
  end

  def get_financial_profile_by_user(%Scope{} = scope) do
    FinancialProfile
    |> where([f], f.user_id == ^scope.user.id)
    |> Repo.one()
  end

  def create_financial_profile(%Scope{} = scope) do
    with {:ok, financial_profile = %FinancialProfile{}} <-
           %FinancialProfile{}
           |> FinancialProfile.changeset(
             %{
               current_savings: 0,
               current_debts: 0,
               monthly_debt_payment: 0,
               net_worth: 0,
               employment_status: :cdi
             },
             scope
           )
           |> Repo.insert() do
      broadcast_financial_profile(scope, {:created, financial_profile})
      {:ok, financial_profile}
    end
  end

  @doc """
  Creates a financial_profile.

  ## Examples

      iex> create_financial_profile(scope, %{field: value})
      {:ok, %FinancialProfile{}}

      iex> create_financial_profile(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_financial_profile(%Scope{} = scope, attrs) do
    with {:ok, financial_profile = %FinancialProfile{}} <-
           %FinancialProfile{}
           |> FinancialProfile.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_financial_profile(scope, {:created, financial_profile})
      {:ok, financial_profile}
    end
  end

  @doc """
  Updates a financial_profile.

  ## Examples

      iex> update_financial_profile(scope, financial_profile, %{field: new_value})
      {:ok, %FinancialProfile{}}

      iex> update_financial_profile(scope, financial_profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_financial_profile(%Scope{} = scope, %FinancialProfile{} = financial_profile, attrs) do
    true = financial_profile.user_id == scope.user.id

    with {:ok, financial_profile = %FinancialProfile{}} <-
           financial_profile
           |> FinancialProfile.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_financial_profile(scope, {:updated, financial_profile})
      {:ok, financial_profile}
    end
  end

  @doc """
  Deletes a financial_profile.

  ## Examples

      iex> delete_financial_profile(scope, financial_profile)
      {:ok, %FinancialProfile{}}

      iex> delete_financial_profile(scope, financial_profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_financial_profile(%Scope{} = scope, %FinancialProfile{} = financial_profile) do
    true = financial_profile.user_id == scope.user.id

    with {:ok, financial_profile = %FinancialProfile{}} <-
           Repo.delete(financial_profile) do
      broadcast_financial_profile(scope, {:deleted, financial_profile})
      {:ok, financial_profile}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking financial_profile changes.

  ## Examples

      iex> change_financial_profile(scope, financial_profile)
      %Ecto.Changeset{data: %FinancialProfile{}}

  """
  def change_financial_profile(
        %Scope{} = scope,
        %FinancialProfile{} = financial_profile,
        attrs \\ %{}
      ) do
    true = financial_profile.user_id == scope.user.id

    FinancialProfile.changeset(financial_profile, attrs, scope)
  end

  @doc """
  Subscribes to scoped notifications about any transaction changes.

  The broadcasted messages match the pattern:

    * {:created, %Transaction{}}
    * {:updated, %Transaction{}}
    * {:deleted, %Transaction{}}

  """
  def subscribe_transactions(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Lifequest.PubSub, "user:#{key}:transactions")
  end

  defp broadcast_transaction(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Lifequest.PubSub, "user:#{key}:transactions", message)
  end

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions(scope)
      [%Transaction{}, ...]

  """
  def list_transactions(%Scope{} = scope) do
    Transaction
    |> join(:inner, [t], a in Account, on: t.account_id == a.id)
    |> where([t, a], a.user_id == ^scope.user.id)
    |> Repo.all()
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(scope, 123)
      %Transaction{}

      iex> get_transaction!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(%Scope{} = scope, id) do
    Transaction
    |> join(:inner, [t], a in Account, on: t.account_id == a.id)
    |> where([t, a], a.user_id == ^scope.user.id)
    |> where([t], t.id == ^id)
    |> Repo.one!()
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(scope, %{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(%Scope{} = scope, attrs) do
    with {:ok, transaction = %Transaction{}} <-
           %Transaction{}
           |> Transaction.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_transaction(scope, {:created, transaction})
      {:ok, transaction}
    end
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(scope, transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(scope, transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Scope{} = scope, %Transaction{} = transaction, attrs) do
    transaction = get_transaction!(scope, transaction.id)

    with {:ok, transaction = %Transaction{}} <-
           transaction
           |> Transaction.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_transaction(scope, {:updated, transaction})
      {:ok, transaction}
    end
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(scope, transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(scope, transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Scope{} = scope, %Transaction{} = transaction) do
    transaction = get_transaction!(scope, transaction.id)

    with {:ok, transaction = %Transaction{}} <-
           Repo.delete(transaction) do
      broadcast_transaction(scope, {:deleted, transaction})
      {:ok, transaction}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(scope, transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Scope{} = scope, %Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs, scope)
  end

  @doc """
  Returns transactions for the given direction and month.
  """
  def list_transactions_for_month(%Scope{} = scope, direction, %Date{} = date) do
    start_of_month = Date.beginning_of_month(date)
    end_of_month = Date.end_of_month(date)

    Transaction
    |> join(:inner, [t], a in Account, on: t.account_id == a.id)
    |> where([t, a], a.user_id == ^scope.user.id)
    |> where([t, a], t.direction == ^direction)
    |> where([t, a], t.is_active == true)
    |> where([t, a], t.date >= ^start_of_month and t.date <= ^end_of_month)
    |> Repo.all()
  end

  @doc """
  Returns recurring transactions from last month that have not
  been duplicated into the current month yet.
  Matching is based on label + direction + type.
  """
  def list_pending_recurring(%Scope{} = scope, direction, %Date{} = date) do
    previous_month = Date.shift(date, month: -1)
    start_of_previous = Date.beginning_of_month(previous_month)
    end_of_previous = Date.end_of_month(previous_month)

    start_of_month = Date.beginning_of_month(date)
    end_of_month = Date.end_of_month(date)

    recurring_last_month =
      Transaction
      |> join(:inner, [t], a in Account, on: t.account_id == a.id)
      |> where([t, a], a.user_id == ^scope.user.id)
      |> where([t, a], t.direction == ^direction)
      |> where([t, a], t.is_recurring == true)
      |> where([t, a], t.is_active == true)
      |> where([t, a], t.date >= ^start_of_previous and t.date <= ^end_of_previous)
      |> Repo.all()

    validated_this_month =
      Transaction
      |> join(:inner, [t], a in Account, on: t.account_id == a.id)
      |> where([t, a], a.user_id == ^scope.user.id)
      |> where([t, a], t.direction == ^direction)
      |> where([t, a], t.date >= ^start_of_month and t.date <= ^end_of_month)
      |> select([t, a], {t.label, t.direction})
      |> Repo.all()
      |> MapSet.new()

    Enum.reject(recurring_last_month, fn t ->
      MapSet.member?(validated_this_month, {t.label, t.direction})
    end)
  end

  @doc """
  Validates a recurring transaction for the given month by duplicating it
  with the date set to the 5th of that month.
  """
  def validate_recurring(%Scope{} = scope, %Transaction{} = transaction, %Date{} = date) do
    create_transaction(scope, %{
      account_id: transaction.account_id,
      label: transaction.label,
      direction: transaction.direction,
      income_type: transaction.income_type,
      expense_type: transaction.expense_type,
      amount: transaction.amount,
      date: Date.new!(date.year, date.month, 5),
      is_recurring: true,
      is_active: true
    })
  end

  @doc """
  Subscribes to scoped notifications about any account changes.

  The broadcasted messages match the pattern:

    * {:created, %Account{}}
    * {:updated, %Account{}}
    * {:deleted, %Account{}}

  """
  def subscribe_accounts(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Lifequest.PubSub, "user:#{key}:accounts")
  end

  defp broadcast_account(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Lifequest.PubSub, "user:#{key}:accounts", message)
  end

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts(scope)
      [%Account{}, ...]

  """
  def list_accounts(%Scope{} = scope) do
    Repo.all_by(Account, user_id: scope.user.id)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(scope, 123)
      %Account{}

      iex> get_account!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(%Scope{} = scope, id) do
    Repo.get_by!(Account, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(scope, %{field: value})
      {:ok, %Account{}}

      iex> create_account(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(%Scope{} = scope, attrs) do
    with {:ok, account = %Account{}} <-
           %Account{}
           |> Account.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_account(scope, {:created, account})
      {:ok, account}
    end
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(scope, account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(scope, account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Scope{} = scope, %Account{} = account, attrs) do
    true = account.user_id == scope.user.id

    with {:ok, account = %Account{}} <-
           account
           |> Account.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_account(scope, {:updated, account})
      {:ok, account}
    end
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(scope, account)
      {:ok, %Account{}}

      iex> delete_account(scope, account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Scope{} = scope, %Account{} = account) do
    true = account.user_id == scope.user.id

    with {:ok, account = %Account{}} <-
           Repo.delete(account) do
      broadcast_account(scope, {:deleted, account})
      {:ok, account}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(scope, account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Scope{} = scope, %Account{} = account, attrs \\ %{}) do
    true = account.user_id == scope.user.id

    Account.changeset(account, attrs, scope)
  end
end
