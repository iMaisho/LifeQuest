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

      assert html =~ "Tableau de bord"
      assert html =~ "Aucun revenu ce mois-ci."
      assert html =~ "Aucune dépense ce mois-ci."
    end

    test "shows add income link", %{conn: conn} do
      {:ok, live_view, _html} = live(conn, ~p"/dashboard")

      assert has_element?(live_view, "a", "Ajouter un revenu")
      assert has_element?(live_view, "a", "Ajouter une dépense")
    end
  end

  describe "Dashboard with income data" do
    test "displays monthly income amounts in legend", %{conn: conn, scope: scope} do
      create_income(scope, %{amount: "2500.00"})
      create_income(scope, %{label: "Freelance gig", income_type: :freelance, amount: "500.00"})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "2500.00 €"
      assert html =~ "500.00 €"
    end

    test "displays income breakdown by type", %{conn: conn, scope: scope} do
      create_income(scope, %{amount: "2500.00", income_type: :salary})
      create_income(scope, %{label: "Freelance", income_type: :freelance, amount: "500.00"})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Salaire"
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

      assert html =~ "Salaire"
      assert html =~ "Freelance"
      assert html =~ "Location"
      assert html =~ "Prime"
      assert html =~ "Retraite"
      assert html =~ "Aides de l&#39;État"
      assert html =~ "Investissement"
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
    test "displays monthly expense amounts in legend", %{conn: conn, scope: scope} do
      create_expense(scope, %{amount: "800.00"})
      create_expense(scope, %{label: "Netflix", expense_type: :pleasure, amount: "15.00"})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "800.00 €"
      assert html =~ "15.00 €"
    end

    test "displays expense breakdown by type", %{conn: conn, scope: scope} do
      create_expense(scope, %{amount: "800.00", expense_type: :essential})
      create_expense(scope, %{label: "Netflix", expense_type: :pleasure, amount: "15.00"})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Essentiel"
      assert html =~ "Loisirs"
    end

    test "displays all expense types", %{conn: conn, scope: scope} do
      for type <- [:essential, :pleasure, :savings, :extra] do
        create_expense(scope, %{label: "#{type}", expense_type: type, amount: "50.00"})
      end

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Essentiel"
      assert html =~ "Loisirs"
      assert html =~ "Épargne"
      assert html =~ "Extra"
    end
  end

  describe "Dashboard with recurring transactions" do
    test "shows pending recurring incomes from last month", %{conn: conn, scope: scope} do
      create_recurring_last_month(scope)

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Revenus récurrents à valider"
      assert html =~ "Recurring salary"
      assert html =~ "3000.00 €"
      assert html =~ "Valider"
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

      assert html =~ "Dépenses récurrentes à valider"
      assert html =~ "Recurring rent"
    end

    test "does not show recurring already validated this month", %{conn: conn, scope: scope} do
      create_recurring_last_month(scope)
      create_income(scope, %{label: "Recurring salary", amount: "3000.00", is_recurring: true})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      refute html =~ "Revenus récurrents à valider"
    end

    test "validate_recurring duplicates transaction to current month", %{conn: conn, scope: scope} do
      create_recurring_last_month(scope)

      {:ok, live_view, _html} = live(conn, ~p"/dashboard")

      assert has_element?(live_view, "button", "Valider")

      live_view
      |> element("button", "Valider")
      |> render_click()

      html = render(live_view)

      refute html =~ "Revenus récurrents à valider"
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

  describe "Donut charts" do
    test "affiche les titres des sections donut", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Revenus mensuels"
      assert html =~ "Dépenses mensuelles"
    end

    test "affiche un SVG quand des revenus existent", %{conn: conn, scope: scope} do
      create_income(scope, %{amount: "1500.00", income_type: :salary})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "<svg"
    end

    test "affiche un SVG quand des dépenses existent", %{conn: conn, scope: scope} do
      create_expense(scope, %{amount: "400.00", expense_type: :essential})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "<svg"
    end

    test "affiche le message vide quand aucun revenu ce mois", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Aucun revenu ce mois-ci."
    end

    test "affiche le message vide quand aucune dépense ce mois", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Aucune dépense ce mois-ci."
    end

    test "affiche les montants par catégorie dans la légende income", %{conn: conn, scope: scope} do
      create_income(scope, %{amount: "2000.00", income_type: :salary})
      create_income(scope, %{amount: "500.00", income_type: :freelance})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "2000.00 €"
      assert html =~ "500.00 €"
    end

    test "affiche les montants par catégorie dans la légende expense", %{conn: conn, scope: scope} do
      create_expense(scope, %{amount: "600.00", expense_type: :essential})
      create_expense(scope, %{amount: "100.00", expense_type: :pleasure})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "600.00 €"
      assert html =~ "100.00 €"
    end

    test "les donuts n'affichent que les données de l'utilisateur connecté", %{
      conn: conn,
      scope: scope
    } do
      other_scope = Lifequest.AccountsFixtures.user_scope_fixture()

      create_income(scope, %{amount: "3000.00", income_type: :salary})
      create_income(other_scope, %{amount: "9000.00", income_type: :salary})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "3000.00 €"
      refute html =~ "9000.00 €"
    end

    test "le donut income affiche les types présents", %{conn: conn, scope: scope} do
      create_income(scope, %{amount: "2000.00", income_type: :salary})
      create_income(scope, %{label: "Freelance", amount: "800.00", income_type: :freelance})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Salaire"
      assert html =~ "Freelance"
    end

    test "le donut expense affiche les types présents", %{conn: conn, scope: scope} do
      create_expense(scope, %{amount: "500.00", expense_type: :essential})
      create_expense(scope, %{label: "Cinema", amount: "50.00", expense_type: :pleasure})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Essentiel"
      assert html =~ "Loisirs"
    end
  end
end
