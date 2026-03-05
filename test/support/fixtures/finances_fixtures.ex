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
end
