defmodule Lifequest.Finances do
  @moduledoc """
  The Finances context.
  """

  import Ecto.Query, warn: false
  alias Lifequest.Repo

  alias Lifequest.Finances.FinancialProfile
  alias Lifequest.Accounts.Scope

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
  def change_financial_profile(%Scope{} = scope, %FinancialProfile{} = financial_profile, attrs \\ %{}) do
    true = financial_profile.user_id == scope.user.id

    FinancialProfile.changeset(financial_profile, attrs, scope)
  end

  alias Lifequest.Finances.IncomeStream
  alias Lifequest.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any income_stream changes.

  The broadcasted messages match the pattern:

    * {:created, %IncomeStream{}}
    * {:updated, %IncomeStream{}}
    * {:deleted, %IncomeStream{}}

  """
  def subscribe_income_streams(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Lifequest.PubSub, "user:#{key}:income_streams")
  end

  defp broadcast_income_stream(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Lifequest.PubSub, "user:#{key}:income_streams", message)
  end

  @doc """
  Returns the list of income_streams.

  ## Examples

      iex> list_income_streams(scope)
      [%IncomeStream{}, ...]

  """
  def list_income_streams(%Scope{} = scope) do
    Repo.all_by(IncomeStream, user_id: scope.user.id)
  end

  @doc """
  Gets a single income_stream.

  Raises `Ecto.NoResultsError` if the Income stream does not exist.

  ## Examples

      iex> get_income_stream!(scope, 123)
      %IncomeStream{}

      iex> get_income_stream!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_income_stream!(%Scope{} = scope, id) do
    Repo.get_by!(IncomeStream, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a income_stream.

  ## Examples

      iex> create_income_stream(scope, %{field: value})
      {:ok, %IncomeStream{}}

      iex> create_income_stream(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_income_stream(%Scope{} = scope, attrs) do
    with {:ok, income_stream = %IncomeStream{}} <-
           %IncomeStream{}
           |> IncomeStream.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_income_stream(scope, {:created, income_stream})
      {:ok, income_stream}
    end
  end

  @doc """
  Updates a income_stream.

  ## Examples

      iex> update_income_stream(scope, income_stream, %{field: new_value})
      {:ok, %IncomeStream{}}

      iex> update_income_stream(scope, income_stream, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_income_stream(%Scope{} = scope, %IncomeStream{} = income_stream, attrs) do
    true = income_stream.user_id == scope.user.id

    with {:ok, income_stream = %IncomeStream{}} <-
           income_stream
           |> IncomeStream.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_income_stream(scope, {:updated, income_stream})
      {:ok, income_stream}
    end
  end

  @doc """
  Deletes a income_stream.

  ## Examples

      iex> delete_income_stream(scope, income_stream)
      {:ok, %IncomeStream{}}

      iex> delete_income_stream(scope, income_stream)
      {:error, %Ecto.Changeset{}}

  """
  def delete_income_stream(%Scope{} = scope, %IncomeStream{} = income_stream) do
    true = income_stream.user_id == scope.user.id

    with {:ok, income_stream = %IncomeStream{}} <-
           Repo.delete(income_stream) do
      broadcast_income_stream(scope, {:deleted, income_stream})
      {:ok, income_stream}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking income_stream changes.

  ## Examples

      iex> change_income_stream(scope, income_stream)
      %Ecto.Changeset{data: %IncomeStream{}}

  """
  def change_income_stream(%Scope{} = scope, %IncomeStream{} = income_stream, attrs \\ %{}) do
    true = income_stream.user_id == scope.user.id

    IncomeStream.changeset(income_stream, attrs, scope)
  end
end
