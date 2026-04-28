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
    |> preload([t, a], account: a)
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
  Returns all transactions for a given direction and category (income_type or expense_type).

  Filters by scope (via account's user_id), direction, and the matching type field.
  Results are ordered by inserted_at descending.

  Returns `[%Transaction{}, ...]`.

  ## Examples

      iex> list_transactions_by_category(scope, :income, :salary)
      [%Transaction{direction: :income, income_type: :salary}, ...]

      iex> list_transactions_by_category(scope, :expense, :essential)
      [%Transaction{direction: :expense, expense_type: :essential}, ...]

  """
  def list_transactions_by_category(%Scope{} = scope, direction, category) do
    type_field = if direction == :income, do: :income_type, else: :expense_type

    Transaction
    |> join(:inner, [t], a in Account, on: t.account_id == a.id)
    |> where([t, a], a.user_id == ^scope.user.id)
    |> where([t, a], t.direction == ^direction)
    |> where([t, a], field(t, ^type_field) == ^category)
    |> order_by([t, a], desc: t.inserted_at)
    |> preload([t, a], account: a)
    |> Repo.all()
  end

  @doc """
  Returns the total amount per category for a given direction.

  Performs a grouped query (group_by + sum) scoped to the user.
  The category field used is `income_type` for `:income` and `expense_type` for `:expense`.

  Returns `%{category_atom => %Decimal{}}`.

  ## Examples

      iex> sum_all_by_category(scope, :income)
      %{salary: #Decimal<3500.00>, freelance: #Decimal<500.00>}

      iex> sum_all_by_category(scope, :expense)
      %{essential: #Decimal<1200.00>, pleasure: #Decimal<350.00>}

  """
  def sum_all_by_category(%Scope{} = scope, direction) do
    type_field = if direction == :income, do: :income_type, else: :expense_type

    Transaction
    |> join(:inner, [t], a in Account, on: t.account_id == a.id)
    |> where([t, a], a.user_id == ^scope.user.id)
    |> where([t, a], t.direction == ^direction)
    |> group_by([t, a], field(t, ^type_field))
    |> select([t, a], {field(t, ^type_field), sum(t.amount)})
    |> Repo.all()
    |> Map.new()
  end

  @doc """
  Returns count, sum and average for a specific category and direction.

  Returns `%{count: integer, sum: Decimal, avg: Decimal}`.
  If no transactions exist, sum and avg default to `Decimal.new(0)`.

  ## Examples

      iex> get_category_statistics(scope, :income, :salary)
      %{count: 3, sum: #Decimal<10500.00>, avg: #Decimal<3500.00>}

      iex> get_category_statistics(scope, :expense, :essential)
      %{count: 0, sum: #Decimal<0>, avg: #Decimal<0>}

  """
  def get_category_statistics(%Scope{} = scope, direction, category) do
    type_field = if direction == :income, do: :income_type, else: :expense_type
    zero = Decimal.new(0)

    result =
      Transaction
      |> join(:inner, [t], a in Account, on: t.account_id == a.id)
      |> where([t, a], a.user_id == ^scope.user.id)
      |> where([t, a], t.direction == ^direction)
      |> where([t, a], field(t, ^type_field) == ^category)
      |> select([t, a], %{
        count: count(t.id),
        sum: sum(t.amount),
        avg: avg(t.amount)
      })
      |> Repo.one()

    %{
      count: result.count || 0,
      sum: result.sum || zero,
      avg: result.avg || zero
    }
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
  Returns all active recurring transactions for the given scope.

  Only transactions with `is_recurring: true` and `is_active: true` are included.
  Results are scoped via the account's user_id (transactions have no direct user_id).

  ## Examples

      iex> list_recurring_transactions(scope)
      [%Transaction{is_recurring: true, is_active: true}, ...]

  """
  def list_recurring_transactions(%Scope{} = scope) do
    Transaction
    |> join(:inner, [t], a in Account, on: t.account_id == a.id)
    |> where([t, a], a.user_id == ^scope.user.id)
    |> where([t], t.is_recurring == true and t.is_active == true)
    |> Repo.all()
  end

  @doc """
  Projects savings and debts month by month from today to the given target date.

  Each month applies:
    1. All active recurring income/expense transactions
    2. Monthly debt repayment: `min(monthly_debt_payment, remaining_debts)`
       The payment is capped to the remaining debt — once debts reach zero,
       no further payment is deducted.

  Returns `{:ok, projection}` or `{:error, :no_profile}` if no financial profile exists.

  The returned projection map contains:
    - `:projected_savings` — savings at target date
    - `:projected_debts` — remaining debts at target date
    - `:monthly_income` — sum of recurring income transactions
    - `:monthly_expenses` — sum of recurring expense transactions
    - `:monthly_debt_payment` — configured monthly repayment amount
    - `:monthly_net` — income minus expenses (before debt repayment)
    - `:monthly_net_after_debt` — net after deducting full monthly repayment
    - `:months` — number of months in the projection
    - `:current_savings` — savings at projection start
    - `:current_debts` — debts at projection start

  ## Examples

      iex> project_savings(scope, ~D[2027-01-01])
      {:ok, %{projected_savings: #Decimal<...>, projected_debts: #Decimal<...>, ...}}

      iex> project_savings(scope_without_profile, ~D[2027-01-01])
      {:error, :no_profile}

  """
  def project_savings(%Scope{} = scope, %Date{} = target_date) do
    profile = get_financial_profile_by_user(scope)

    if is_nil(profile) do
      {:error, :no_profile}
    else
      build_projection(scope, profile, target_date)
    end
  end

  # Calcule les montants mensuels et délègue la simulation mois par mois.
  defp build_projection(scope, profile, target_date) do
    transactions = list_recurring_transactions(scope)
    zero = Decimal.new(0)

    monthly_income =
      transactions
      |> Enum.filter(&(&1.direction == :income))
      |> Enum.reduce(zero, &Decimal.add(&2, &1.amount))

    monthly_expenses =
      transactions
      |> Enum.filter(&(&1.direction == :expense))
      |> Enum.reduce(zero, &Decimal.add(&2, &1.amount))

    monthly_net = Decimal.sub(monthly_income, monthly_expenses)
    months = months_until(target_date)

    {final_savings, final_debts} =
      simulate_months(
        months,
        profile.current_savings,
        profile.current_debts,
        monthly_net,
        profile.monthly_debt_payment
      )

    {:ok,
     %{
       projected_savings: final_savings,
       projected_debts: final_debts,
       monthly_income: monthly_income,
       monthly_expenses: monthly_expenses,
       monthly_debt_payment: profile.monthly_debt_payment,
       monthly_net: monthly_net,
       monthly_net_after_debt: Decimal.sub(monthly_net, profile.monthly_debt_payment),
       months: months,
       current_savings: profile.current_savings,
       current_debts: profile.current_debts
     }}
  end

  # Applique récursivement chaque mois : revenu net + remboursement plafonné aux dettes restantes.
  defp simulate_months(0, savings, debts, _net, _payment), do: {savings, debts}

  defp simulate_months(months, savings, debts, monthly_net, monthly_payment) do
    savings = Decimal.add(savings, monthly_net)
    effective_payment = Decimal.min(monthly_payment, debts)
    savings = Decimal.sub(savings, effective_payment)
    debts = Decimal.sub(debts, effective_payment)
    simulate_months(months - 1, savings, debts, monthly_net, monthly_payment)
  end

  defp months_until(%Date{} = target_date) do
    today = Date.utc_today()
    (target_date.year - today.year) * 12 + (target_date.month - today.month)
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
