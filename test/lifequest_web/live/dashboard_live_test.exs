defmodule LifequestWeb.DashboardLive.IndexTest do
  use LifequestWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lifequest.FinancesFixtures

  setup :register_and_log_in_user

  defp create_income(scope, attrs) do
    transaction_fixture(
      scope,
      Map.merge(
        %{
          label: "Test salary",
          direction: :income,
          income_type: :salary,
          amount: "2500.00",
          date: Date.utc_today(),
          is_recurring: false,
          is_active: true
        },
        attrs
      )
    )
  end

  defp create_expense(scope, attrs) do
    transaction_fixture(
      scope,
      Map.merge(
        %{
          label: "Test rent",
          direction: :expense,
          expense_type: :essential,
          amount: "800.00",
          date: Date.utc_today(),
          is_recurring: false,
          is_active: true
        },
        attrs
      )
    )
  end

  defp create_recurring_last_month(scope, attrs \\ %{}) do
    last_month = Date.shift(Date.utc_today(), month: -1)

    transaction_fixture(
      scope,
      Map.merge(
        %{
          label: "Recurring salary",
          direction: :income,
          income_type: :salary,
          amount: "3000.00",
          date: Date.new!(last_month.year, last_month.month, 5),
          is_recurring: true,
          is_active: true
        },
        attrs
      )
    )
  end

  describe "Dashboard with no data" do
    test "renders empty states", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Dashboard"
      assert html =~ "No income this month."
      assert html =~ "No expenses this month."
    end

    test "shows add income link", %{conn: conn} do
      {:ok, live_view, _html} = live(conn, ~p"/dashboard")

      assert has_element?(live_view, "a", "Add income")
      assert has_element?(live_view, "a", "Add expense")
    end
  end

  describe "Dashboard with income data" do
    test "displays total monthly income", %{conn: conn, scope: scope} do
      create_income(scope, %{amount: "2500.00"})
      create_income(scope, %{label: "Freelance gig", income_type: :freelance, amount: "500.00"})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "3000.00 €"
    end

    test "displays income breakdown by type", %{conn: conn, scope: scope} do
      create_income(scope, %{amount: "2500.00", income_type: :salary})
      create_income(scope, %{label: "Freelance", income_type: :freelance, amount: "500.00"})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Salary"
      assert html =~ "Freelance"
      assert html =~ "2500.00 €"
      assert html =~ "500.00 €"
    end

    test "displays all income types", %{conn: conn, scope: scope} do
      for {type, label} <- [
            {:salary, "Salary"},
            {:freelance, "Freelance"},
            {:rental, "Rental"},
            {:bonus, "Bonus"},
            {:pension, "Pension"},
            {:government_aid, "Government aid"},
            {:investment, "Investment"}
          ] do
        create_income(scope, %{label: label, income_type: type, amount: "100.00"})
      end

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Salary"
      assert html =~ "Freelance"
      assert html =~ "Rental"
      assert html =~ "Bonus"
      assert html =~ "Pension"
      assert html =~ "Government aid"
      assert html =~ "Investment"
    end

    test "does not show income from other months", %{conn: conn, scope: scope} do
      last_month = Date.shift(Date.utc_today(), month: -1)
      create_income(scope, %{amount: "2500.00", date: Date.utc_today()})
      create_income(scope, %{label: "Old income", amount: "1000.00", date: last_month})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "2500.00 €"
      refute html =~ "Old income"
    end

    test "does not show inactive income", %{conn: conn, scope: scope} do
      create_income(scope, %{amount: "2500.00"})
      create_income(scope, %{label: "Inactive", amount: "1000.00", is_active: false})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "2500.00 €"
      refute html =~ "Inactive"
    end
  end

  describe "Dashboard with expense data" do
    test "displays total monthly expenses", %{conn: conn, scope: scope} do
      create_expense(scope, %{amount: "800.00"})
      create_expense(scope, %{label: "Netflix", expense_type: :pleasure, amount: "15.00"})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "815.00 €"
    end

    test "displays expense breakdown by type", %{conn: conn, scope: scope} do
      create_expense(scope, %{amount: "800.00", expense_type: :essential})
      create_expense(scope, %{label: "Netflix", expense_type: :pleasure, amount: "15.00"})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Essential"
      assert html =~ "Pleasure"
    end

    test "displays all expense types", %{conn: conn, scope: scope} do
      for type <- [:essential, :pleasure, :savings, :extra] do
        create_expense(scope, %{label: "#{type}", expense_type: type, amount: "50.00"})
      end

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Essential"
      assert html =~ "Pleasure"
      assert html =~ "Savings"
      assert html =~ "Extra"
    end
  end

  describe "Dashboard with recurring transactions" do
    test "shows pending recurring incomes from last month", %{conn: conn, scope: scope} do
      create_recurring_last_month(scope)

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Recurring income to validate"
      assert html =~ "Recurring salary"
      assert html =~ "3000.00 €"
      assert html =~ "Validate"
    end

    test "shows pending recurring expenses from last month", %{conn: conn, scope: scope} do
      last_month = Date.shift(Date.utc_today(), month: -1)

      create_recurring_last_month(scope, %{
        label: "Recurring rent",
        direction: :expense,
        income_type: nil,
        expense_type: :essential,
        amount: "800.00",
        date: Date.new!(last_month.year, last_month.month, 5)
      })

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Recurring expenses to validate"
      assert html =~ "Recurring rent"
    end

    test "does not show recurring already validated this month", %{conn: conn, scope: scope} do
      create_recurring_last_month(scope)
      create_income(scope, %{label: "Recurring salary", amount: "3000.00", is_recurring: true})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      refute html =~ "Recurring income to validate"
    end

    test "validate_recurring duplicates transaction to current month", %{conn: conn, scope: scope} do
      create_recurring_last_month(scope)

      {:ok, live_view, _html} = live(conn, ~p"/dashboard")

      assert has_element?(live_view, "button", "Validate")

      live_view
      |> element("button", "Validate")
      |> render_click()

      html = render(live_view)

      refute html =~ "Recurring income to validate"
      assert html =~ "3000.00 €"
    end
  end

  describe "Dashboard scoping" do
    test "does not show other users transactions", %{conn: conn, scope: scope} do
      other_scope = Lifequest.AccountsFixtures.user_scope_fixture()

      create_income(scope, %{amount: "2500.00"})
      create_income(other_scope, %{amount: "5000.00"})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "2500.00 €"
      refute html =~ "5000.00 €"
    end
  end

  describe "Dashboard displays current month" do
    test "shows current month and year", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/dashboard")

      expected_month = Calendar.strftime(Date.utc_today(), "%B %Y") |> String.capitalize()
      assert html =~ expected_month
    end
  end
end
