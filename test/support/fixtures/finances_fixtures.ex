defmodule Lifequest.FinancesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lifequest.Finances` context.
  """

  @doc """
  Generate a financial_profile.
  """
  def financial_profile_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        current_debts: "120.50",
        current_savings: "120.50",
        employment_status: :cdi,
        monthly_debt_payment: "120.50",
        net_worth: "120.50"
      })

    {:ok, financial_profile} = Lifequest.Finances.create_financial_profile(scope, attrs)
    financial_profile
  end

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(scope, attrs \\ %{}) do
    account_id = Map.get(attrs, :account_id) || account_fixture(scope).id

    attrs =
      attrs
      |> Map.put_new(:account_id, account_id)
      |> Enum.into(%{
        amount: "120.50",
        date: ~D[2026-03-05],
        direction: :income,
        income_type: :salary,
        is_active: true,
        is_recurring: false,
        label: "some label"
      })

    {:ok, transaction} = Lifequest.Finances.create_transaction(scope, attrs)
    transaction
  end

  @doc """
  Generate a account.
  """
  def account_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        balance: "1000.00",
        interest_rate: "2.500",
        is_active: true,
        label: "Compte courant",
        type: :checking
      })

    {:ok, account} = Lifequest.Finances.create_account(scope, attrs)
    account
  end
end
