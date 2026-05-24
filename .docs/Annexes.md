# Annexes

## 1.1 Diagramme de Séquence LiveView

<img src="file:///C:/Users/anton/IdeaProjects/lifequest/.docs/img/1.Sequence_Liveview.png" style="width:100%; max-width:100%;" alt="Diagramme de Séquence LiveView" />

## 2.1 Exemple d'utilisation de LiveView : `dashboard_live`

```elixir
defmodule LifequestWeb.DashboardLive.Index do
  use LifequestWeb, :live_view

  alias Lifequest.Finances

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <h1 class="text-4xl font-bold mb-2">{gettext("Dashboard")}</h1>
      <p class="text-sm opacity-70 mb-8">
        {format_month(@current_month)}
      </p>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-12">
        <.donut_chart
          title={gettext("Monthly income")}
          slices={@income_slices}
          empty_label={gettext("No income this month.")}
        />
        <.donut_chart
          title={gettext("Monthly expenses")}
          slices={@expense_slices}
          empty_label={gettext("No expenses this month.")}
        />
      </div>

      <.pending_recurring_section direction={:income} pending={@pending_incomes} />
      <.pending_recurring_section direction={:expense} pending={@pending_expenses} />

      <.empty_state :if={@incomes == [] and @pending_incomes == []} direction={:income} />
      <.empty_state :if={@expenses == [] and @pending_expenses == []} direction={:expense} />
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    today = Date.utc_today()

    {:ok,
     socket
     |> assign(:page_title, gettext("Dashboard"))
     |> assign(:current_month, today)
     |> load_dashboard_data(scope, today)}
  end

  defp load_dashboard_data(socket, scope, date) do
    incomes = Finances.list_transactions_for_month(scope, :income, date)
    expenses = Finances.list_transactions_for_month(scope, :expense, date)
    pending_incomes = Finances.list_pending_recurring(scope, :income, date)
    pending_expenses = Finances.list_pending_recurring(scope, :expense, date)

    socket
    |> assign(:incomes, incomes)
    |> assign(:expenses, expenses)
    |> assign(:pending_incomes, pending_incomes)
    |> assign(:pending_expenses, pending_expenses)
  end

  # --- Events ---

  @impl true
  def handle_event("validate_recurring", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    transaction = Finances.get_transaction!(scope, id)
    date = socket.assigns.current_month

    case Finances.validate_recurring(scope, transaction, date) do
      {:ok, _new_transaction} ->
        {:noreply, load_dashboard_data(socket, scope, date)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, gettext("Error validating transaction"))}
    end
  end

  defp pending_recurring_section(assigns) do
    ~H"""
    <div :if={@pending != []} class="card bg-warning/10 shadow mb-8">
      <div class="card-body">
        <h2 class="card-title mb-4">{pending_title(@direction)}</h2>
        <div class="space-y-3">
          <div :for={transaction <- @pending} class="flex justify-between items-center">
            <div>
              <span class="font-medium">{transaction.label}</span>
              <span class="badge badge-outline badge-sm ml-2">
                {format_transaction_type(transaction)}
              </span>
            </div>
            <div class="flex items-center gap-3">
              <span>{format_currency(transaction.amount)}</span>
              <button
                phx-click="validate_recurring"
                phx-value-id={transaction.id}
                class="btn btn-primary btn-sm"
              >
                {gettext("Validate")}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
```

## 2.2 Exemple de tests unitaires Frontend : `dashboard_live_test`

```elixir
defmodule LifequestWeb.DashboardLive.IndexTest do
  use LifequestWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lifequest.FinancesFixtures

  setup :register_and_log_in_user

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
end
```

## 3.1 Pattern matching : clauses multiples et gestion des retours

```elixir
defp format_transaction_type(%{direction: :income, income_type: type}),
  do: format_income_type(type)

defp format_transaction_type(%{direction: :expense, expense_type: type}),
  do: format_expense_type(type)


defp format_income_type(:salary), do: gettext("Salary")
defp format_income_type(:freelance), do: gettext("Freelance")
defp format_income_type(:rental), do: gettext("Rental")
defp format_income_type(:bonus), do: gettext("Bonus")
defp format_income_type(_), do: gettext("Unknown")
```

```elixir
def handle_event("validate_recurring", %{"id" => id}, socket) do
  scope = socket.assigns.current_scope
  transaction = Finances.get_transaction!(scope, id)
  date = socket.assigns.current_month

  case Finances.validate_recurring(scope, transaction, date) do
    {:ok, _new_transaction} ->
      {:noreply, load_dashboard_data(socket, scope, date)}

    {:error, _changeset} ->
      {:noreply, put_flash(socket, :error, gettext("Error validating transaction"))}
  end
end
```

## 3.2 Tests unitaires du contexte `Finances` : isolation par scope

```elixir
describe "transactions" do
  import Lifequest.AccountsFixtures, only: [user_scope_fixture: 0]
  import Lifequest.FinancesFixtures

  test "list_transactions/1 returns all scoped transactions" do
    scope = user_scope_fixture()
    other_scope = user_scope_fixture()
    transaction = transaction_fixture(scope)
    other_transaction = transaction_fixture(other_scope)

    assert [result] = Finances.list_transactions(scope)
    assert result.id == transaction.id

    assert [other_result] = Finances.list_transactions(other_scope)
    assert other_result.id == other_transaction.id
  end

  test "get_transaction!/2 returns the transaction with given id" do
    scope = user_scope_fixture()
    transaction = transaction_fixture(scope)
    other_scope = user_scope_fixture()

    assert Finances.get_transaction!(scope, transaction.id) == transaction

    assert_raise Ecto.NoResultsError, fn ->
      Finances.get_transaction!(other_scope, transaction.id)
    end
  end
end
```

## 3.3 Définition d'une fixture : Transaction
```elixir
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
  ```

## 4.1 Plan de tests

### Contexte `Finances` : Tests unitaires

| ID  | Fonctionnalité                                   | Précondition                                      | Action                                                                        | Résultat attendu                                                               | Statut |
| --- | ------------------------------------------------ | ------------------------------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------ | ------ |
| T01 | `list_transactions/1` : cas nominal              | 1 transaction créée pour le scope actif           | Appeler `list_transactions(scope)`                                            | Retourne une liste avec la transaction, association `account` préchargée       | ✅     |
| T02 | `list_transactions/1` : isolation scope          | 1 transaction par utilisateur                     | Appeler avec `scope` et `other_scope` séparément                              | Chaque scope ne voit que sa propre transaction                                 | ✅     |
| T03 | `get_transaction!/2` : cas nominal               | 1 transaction créée pour le scope                 | Appeler `get_transaction!(scope, id)`                                         | Retourne la transaction correspondante                                         | ✅     |
| T04 | `get_transaction!/2` : isolation scope           | Transaction créée pour `scope`                    | Appeler `get_transaction!(other_scope, id)`                                   | Lève `Ecto.NoResultsError`                                                     | ✅     |
| T05 | `create_transaction/2` : données valides         | Compte existant pour le scope                     | Appeler avec attributs complets (label, direction, income_type, amount, date) | Retourne `{:ok, %Transaction{}}`, `expense_type` est `nil` pour un revenu      | ✅     |
| T06 | `create_transaction/2` : données invalides       | Scope existant                                    | Appeler avec `@invalid_attrs` (tous les champs à `nil`)                       | Retourne `{:error, %Ecto.Changeset{}}`                                         | ✅     |
| T07 | `update_transaction/3` : données valides         | Transaction existante                             | Mettre à jour label, direction, amount                                        | Retourne `{:ok, %Transaction{}}` avec les nouvelles valeurs                    | ✅     |
| T08 | `update_transaction/3` : scope invalide          | Transaction créée pour `scope`                    | Appeler `update_transaction(other_scope, transaction, %{})`                   | Lève `Ecto.NoResultsError`                                                     | ✅     |
| T09 | `update_transaction/3` : données invalides       | Transaction existante                             | Appeler avec `@invalid_attrs` puis relire en base                             | Retourne `{:error, changeset}`, l'enregistrement en base est inchangé          | ✅     |
| T10 | `delete_transaction/2` : cas nominal             | Transaction existante                             | Appeler `delete_transaction(scope, transaction)`                              | Retourne `{:ok, %Transaction{}}`, la transaction n'existe plus en base         | ✅     |
| T11 | `delete_transaction/2` : scope invalide          | Transaction créée pour `scope`                    | Appeler `delete_transaction(other_scope, transaction)`                        | Lève `Ecto.NoResultsError`                                                     | ✅     |
| T12 | `sum_all_by_category/2` : totaux corrects        | 2 transactions salary + 1 freelance               | Appeler `sum_all_by_category(scope, :income)`                                 | Retourne `%{salary: 1500.00, freelance: 300.00}`                               | ✅     |
| T13 | `sum_all_by_category/2` : catégorie absente      | 1 transaction salary                              | Vérifier la clé `:freelance` dans la map retournée                            | La clé est absente (pas de valeur à zéro)                                      | ✅     |
| T14 | `project_savings/2` : sans profil                | Aucun profil financier pour le scope              | Appeler `project_savings(scope, date)`                                        | Retourne `{:error, :no_profile}`                                               | ✅     |
| T15 | `project_savings/2` : avec récurrents            | Profil + 1 revenu récurrent 500€ + 1 dépense 200€ | Projeter sur 3 mois depuis 1000€ d'épargne                                    | `projected_savings == 1900.00` (1000 + 300×3)                                  | ✅     |
| T16 | `project_savings/2` : dette partiellement soldée | Profil avec 150€ de dettes, mensualité 100€       | Projeter sur 3 mois                                                           | `projected_savings == 850.00`, `projected_debts == 0` (plafonnement au mois 2) | ✅     |
| T17 | `delete_all_user_data/1` : suppression complète  | Profil, compte et transaction créés               | Appeler `delete_all_user_data(scope)`                                         | Retourne `:ok`, aucune donnée restante en base pour ce scope                   | ✅     |
| T18 | `delete_all_user_data/1` : isolation scope       | Données pour `scope` et `other_scope`             | Supprimer les données de `scope`                                              | Les données de `other_scope` sont intactes                                     | ✅     |

### LiveView : Tests d'intégration

| ID  | Fonctionnalité                                    | Précondition                                         | Action                                                                | Résultat attendu                                                                                        | Statut |
| --- | ------------------------------------------------- | ---------------------------------------------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | ------ |
| T19 | Dashboard : rendu                                 | Utilisateur connecté                                 | Naviguer vers `/dashboard`                                            | La page s'affiche                                                                                       | ✅     |
| T20 | Dashboard : redirect non authentifié              | Connexion anonyme                                    | `live(build_conn(), ~p"/dashboard")`                                  | Redirige vers `/users/log-in`                                                                           | ✅     |
| T21 | Dashboard : revenus récurrents à valider          | Transaction récurrente créée le mois précédent       | Monter le Dashboard                                                   | La section "Revenus récurrents à valider" s'affiche avec le montant                                     | ✅     |
| T22 | Dashboard : validation d'un récurrent             | Revenu récurrent en attente affiché                  | Cliquer sur "Valider"                                                 | La section disparaît, le revenu apparaît dans les transactions du mois                                  | ✅     |
| T23 | Dashboard : pas de doublons si déjà validé        | Récurrent créé le mois dernier + déjà validé ce mois | Monter le Dashboard                                                   | La section "à valider" n'apparaît pas                                                                   | ✅     |
| T24 | Formulaire transaction : rendu revenu             | Utilisateur connecté, compte existant                | Naviguer vers `/transactions/new?direction=income&income_type=salary` | Le titre "Nouveau revenu" s'affiche, les champs `direction` et `income_type` sont pré-remplis en hidden | ✅     |
| T25 | Formulaire transaction : création revenu          | Formulaire rendu                                     | Soumettre le formulaire avec données valides                          | Redirige vers `/finances` avec le message "Transaction créée avec succès"                               | ✅     |
| T26 | Formulaire transaction : erreurs de validation    | Formulaire rendu                                     | Soumettre avec des champs vides                                       | Les messages d'erreur "ne peut pas être vide" s'affichent, pas de redirection                           | ✅     |
| T27 | Formulaire transaction : création dépense         | Utilisateur connecté, compte existant                | Soumettre un formulaire dépense valide                                | Redirige vers `/finances` avec confirmation                                                             | ✅     |
| T28 | Formulaire transaction : redirect non authentifié | Connexion anonyme                                    | Naviguer vers `/transactions/new`                                     | Redirige vers `/users/log-in`                                                                           | ✅     |
