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
  Generate a income_stream.
  """
  def income_stream_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        amount: "120.50",
        end_date: ~D[2026-03-04],
        frequency: :weekly,
        is_active: true,
        label: "some label",
        start_date: ~D[2026-03-04],
        type: :salary
      })

    {:ok, income_stream} = Lifequest.Finances.create_income_stream(scope, attrs)
    income_stream
  end

  @doc """
  Generate a expense.
  """
  def expense_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        amount: "120.50",
        frequency: :weekly,
        name: "some name",
        type: :essential
      })

    {:ok, expense} = Lifequest.Finances.create_expense(scope, attrs)
    expense
  end
end
