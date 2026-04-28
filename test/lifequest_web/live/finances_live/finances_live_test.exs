defmodule LifequestWeb.FinancesLive.IndexTest do
  use LifequestWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lifequest.FinancesFixtures

  setup :register_and_log_in_user

  describe "Finances page renders" do
    test "displays page title", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/finances")

      assert html =~ "Financial information"
    end

    test "displays financial profile section", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/finances")

      assert html =~ "Financial profile"
      assert html =~ "Current savings"
      assert html =~ "Current debts"
      assert html =~ "Monthly debt payment"
      assert html =~ "Net worth"
      assert html =~ "Employment status"
    end

    test "displays income sources section", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/finances")

      assert html =~ "Income sources"
      assert html =~ "Salary"
      assert html =~ "Freelance"
      assert html =~ "Rental"
      assert html =~ "Bonus"
      assert html =~ "Pension"
      assert html =~ "Government aid"
      assert html =~ "Investment"
    end

    test "displays expenses section", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/finances")

      assert html =~ "Expenses"
      assert html =~ "Essential"
      assert html =~ "Pleasure"
      assert html =~ "Savings"
      assert html =~ "Extra"
    end
  end

  describe "Financial profile cards" do
    test "shows 'Not set' when no profile exists", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/finances")

      assert html =~ "Not set"
    end

    test "shows current values when profile exists", %{conn: conn, scope: scope} do
      financial_profile_fixture(scope, %{
        current_savings: "5000.00",
        current_debts: "1000.00",
        monthly_debt_payment: "200.00",
        net_worth: "50000.00",
        employment_status: :cdi
      })

      {:ok, _live, html} = live(conn, ~p"/finances")

      assert html =~ "5000.00 €"
      assert html =~ "1000.00 €"
      assert html =~ "200.00 €"
      assert html =~ "50000.00 €"
      assert html =~ "Permanent contract"
    end

    test "links to new profile when none exists", %{conn: conn} do
      {:ok, live_view, _html} = live(conn, ~p"/finances")

      assert has_element?(live_view, "a[href='/financial_profiles/new']")
    end

    test "links to edit profile with field param when profile exists", %{conn: conn, scope: scope} do
      financial_profile_fixture(scope)

      {:ok, live_view, _html} = live(conn, ~p"/finances")

      assert has_element?(live_view, "a[href*='field=current_savings']")
      assert has_element?(live_view, "a[href*='field=employment_status']")
    end
  end

  describe "Income source cards navigation" do
    test "salary card links to transaction form with correct params", %{conn: conn} do
      {:ok, live_view, _html} = live(conn, ~p"/finances")

      assert has_element?(live_view, "a[href*='direction=income'][href*='income_type=salary']")
    end

    test "freelance card links to transaction form with correct params", %{conn: conn} do
      {:ok, live_view, _html} = live(conn, ~p"/finances")

      assert has_element?(live_view, "a[href*='direction=income'][href*='income_type=freelance']")
    end
  end

  describe "Transactions groupées par catégorie" do
    test "affiche les transactions income dans la page", %{conn: conn, scope: scope} do
      transaction_fixture(scope, %{
        direction: :income,
        income_type: :salary,
        label: "Mon salaire"
      })

      {:ok, _live, html} = live(conn, ~p"/finances")

      assert html =~ "Mon salaire"
    end

    test "affiche 'No transactions yet' pour les catégories sans transactions", %{
      conn: conn,
      scope: scope
    } do
      transaction_fixture(scope, %{direction: :income, income_type: :salary, label: "Mon salaire"})

      {:ok, _live, html} = live(conn, ~p"/finances")

      assert html =~ "No transactions yet"
    end

    test "affiche le montant de la transaction dans la catégorie", %{conn: conn, scope: scope} do
      transaction_fixture(scope, %{
        direction: :income,
        income_type: :salary,
        amount: "2500.00",
        label: "Salaire mars"
      })

      {:ok, _live, html} = live(conn, ~p"/finances")

      assert html =~ "2500.00"
    end

    test "affiche les transactions expense dans la page", %{conn: conn, scope: scope} do
      transaction_fixture(scope, %{
        direction: :expense,
        expense_type: :essential,
        label: "Loyer mensuel"
      })

      {:ok, _live, html} = live(conn, ~p"/finances")

      assert html =~ "Loyer mensuel"
    end

    test "les transactions d'un autre scope ne sont pas visibles", %{conn: conn} do
      other_scope = Lifequest.AccountsFixtures.user_scope_fixture()

      transaction_fixture(other_scope, %{
        direction: :income,
        income_type: :salary,
        label: "Salaire autre utilisateur"
      })

      {:ok, _live, html} = live(conn, ~p"/finances")

      refute html =~ "Salaire autre utilisateur"
    end

    test "les transactions income et expense apparaissent toutes les deux dans la page", %{
      conn: conn,
      scope: scope
    } do
      transaction_fixture(scope, %{
        direction: :income,
        income_type: :salary,
        label: "Revenu salary unique"
      })

      transaction_fixture(scope, %{
        direction: :expense,
        expense_type: :essential,
        label: "Depense essential unique"
      })

      {:ok, _live, html} = live(conn, ~p"/finances")

      assert html =~ "Revenu salary unique"
      assert html =~ "Depense essential unique"
    end
  end

  describe "Expense cards navigation" do
    test "essential card links to transaction form with correct params", %{conn: conn} do
      {:ok, live_view, _html} = live(conn, ~p"/finances")

      assert has_element?(
               live_view,
               "a[href*='direction=expense'][href*='expense_type=essential']"
             )
    end

    test "pleasure card links to transaction form with correct params", %{conn: conn} do
      {:ok, live_view, _html} = live(conn, ~p"/finances")

      assert has_element?(
               live_view,
               "a[href*='direction=expense'][href*='expense_type=pleasure']"
             )
    end
  end
end
