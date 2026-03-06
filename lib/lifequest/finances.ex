defmodule Lifequest.Finances do
  @moduledoc """
  The Finances context.
  """

  import Ecto.Query, warn: false

  alias Lifequest.Accounts.Scope
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
    Repo.all_by(Transaction, user_id: scope.user.id)
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
    Repo.get_by!(Transaction, id: id, user_id: scope.user.id)
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
    true = transaction.user_id == scope.user.id

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
    true = transaction.user_id == scope.user.id

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
    true = transaction.user_id == scope.user.id

    Transaction.changeset(transaction, attrs, scope)
  end
end
