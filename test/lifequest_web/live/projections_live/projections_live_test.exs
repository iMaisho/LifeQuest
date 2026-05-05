defmodule LifequestWeb.ProjectionsLive.IndexTest do
  use LifequestWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lifequest.AccountsFixtures, only: [user_scope_fixture: 0]
  import Lifequest.FinancesFixtures

  setup :register_and_log_in_user

  describe "Page rendering" do
    test "renders page title and form", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/projections")

      assert html =~ "Projections"
      assert html =~ "Projeter mes finances"
    end

    test "does not show results before calculating", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/projections")

      refute html =~ "Épargne projetée"
      refute html =~ "Dettes restantes"
    end

    test "redirects when not authenticated" do
      conn = build_conn()
      assert {:error, {:redirect, %{to: path}}} = live(conn, ~p"/projections")
      assert path == ~p"/users/log-in"
    end
  end

  describe "Projection with no financial profile" do
    test "shows warning after submitting form", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/projections")

      html =
        live
        |> form("form", projection: %{target_date: Date.to_iso8601(months_ahead(6))})
        |> render_submit()

      assert html =~ "profil financier"
    end
  end

  describe "Projection results" do
    test "displays result cards after calculating", %{conn: conn, scope: scope} do
      financial_profile_fixture(scope, %{
        current_savings: "1000.00",
        current_debts: "0.00",
        monthly_debt_payment: "0.00"
      })

      {:ok, live, _html} = live(conn, ~p"/projections")

      html =
        live
        |> form("form", projection: %{target_date: Date.to_iso8601(months_ahead(3))})
        |> render_submit()

      assert html =~ "Épargne projetée"
      assert html =~ "Dettes restantes"
      assert html =~ "Évolution nette mensuelle"
    end

    test "shows correct projected savings with recurring income", %{conn: conn, scope: scope} do
      financial_profile_fixture(scope, %{
        current_savings: "1000.00",
        current_debts: "0.00",
        monthly_debt_payment: "0.00"
      })

      transaction_fixture(scope, %{
        direction: :income,
        income_type: :salary,
        amount: "500.00",
        is_recurring: true,
        is_active: true
      })

      {:ok, live, _html} = live(conn, ~p"/projections")

      html =
        live
        |> form("form", projection: %{target_date: Date.to_iso8601(months_ahead(1))})
        |> render_submit()

      # 1000 + 500 = 1500
      assert html =~ "1500.00"
    end

    test "shows correct projected debts with monthly payment", %{conn: conn, scope: scope} do
      financial_profile_fixture(scope, %{
        current_savings: "1000.00",
        current_debts: "300.00",
        monthly_debt_payment: "100.00"
      })

      {:ok, live, _html} = live(conn, ~p"/projections")

      html =
        live
        |> form("form", projection: %{target_date: Date.to_iso8601(months_ahead(1))})
        |> render_submit()

      # savings: 1000 - 100 = 900, debts: 300 - 100 = 200
      assert html =~ "900.00"
      assert html =~ "200.00"
    end

    test "projection does not include other users transactions", %{conn: conn, scope: scope} do
      financial_profile_fixture(scope, %{
        current_savings: "1000.00",
        current_debts: "0.00",
        monthly_debt_payment: "0.00"
      })

      other_scope = user_scope_fixture()

      transaction_fixture(other_scope, %{
        direction: :income,
        income_type: :salary,
        amount: "9999.00",
        is_recurring: true,
        is_active: true
      })

      {:ok, live, _html} = live(conn, ~p"/projections")

      html =
        live
        |> form("form", projection: %{target_date: Date.to_iso8601(months_ahead(1))})
        |> render_submit()

      # savings should be 1000.00, not 10999.00
      assert html =~ "1000.00"
      refute html =~ "10999"
    end
  end

  describe "Validation" do
    test "shows error flash for past date", %{conn: conn, scope: scope} do
      financial_profile_fixture(scope)
      past_date = Date.add(Date.utc_today(), -30)

      {:ok, live, _html} = live(conn, ~p"/projections")

      html =
        live
        |> form("form", projection: %{target_date: Date.to_iso8601(past_date)})
        |> render_submit()

      assert html =~ "date future valide"
    end
  end

  defp months_ahead(n) do
    today = Date.utc_today()
    total = today.month + n
    Date.new!(today.year + div(total - 1, 12), rem(total - 1, 12) + 1, 1)
  end
end
