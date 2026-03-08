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

      <.transaction_section
        direction={:income}
        transactions={@incomes}
        pending={@pending_incomes}
        total={@total_income}
        by_type={@income_by_type}
      />

      <.transaction_section
        direction={:expense}
        transactions={@expenses}
        pending={@pending_expenses}
        total={@total_expense}
        by_type={@expense_by_type}
      />
    </Layouts.app>
    """
  end

  # --- Components ---

  defp transaction_section(assigns) do
    ~H"""
    <div class="mb-12">
      <.transaction_summary direction={@direction} total={@total} by_type={@by_type} />
      <.pending_recurring_section direction={@direction} pending={@pending} />
      <.empty_state :if={@transactions == [] and @pending == []} direction={@direction} />
    </div>
    """
  end

  defp transaction_summary(assigns) do
    ~H"""
    <div class="card bg-base-200 shadow mb-8">
      <div class="card-body">
        <h2 class="card-title">{direction_title(@direction)}</h2>
        <p class="text-3xl font-bold">{format_currency(@total)}</p>
      </div>
    </div>

    <div :if={@by_type != []} class="card bg-base-200 shadow mb-8">
      <div class="card-body">
        <h2 class="card-title mb-4">{gettext("Breakdown by type")}</h2>
        <div class="space-y-3">
          <div :for={{type, amount} <- @by_type} class="flex justify-between items-center">
            <span class="badge badge-outline">{format_type(@direction, type)}</span>
            <span class="font-semibold">{format_currency(amount)}</span>
          </div>
        </div>
      </div>
    </div>
    """
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

  defp empty_state(assigns) do
    ~H"""
    <div class="alert alert-info">
      <span>{empty_message(@direction)}</span>
      <.link navigate={~p"/transactions/new"} class="btn btn-sm btn-primary">
        {add_label(@direction)}
      </.link>
    </div>
    """
  end

  # --- Mount & Data Loading ---

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
    |> assign(:total_income, sum_amounts(incomes))
    |> assign(:total_expense, sum_amounts(expenses))
    |> assign(:income_by_type, group_by_type(incomes, :income_type))
    |> assign(:expense_by_type, group_by_type(expenses, :expense_type))
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

  # --- Direction-aware Labels ---

  defp direction_title(:income), do: gettext("Monthly income")
  defp direction_title(:expense), do: gettext("Monthly expenses")

  defp pending_title(:income), do: gettext("Recurring income to validate")
  defp pending_title(:expense), do: gettext("Recurring expenses to validate")

  defp empty_message(:income), do: gettext("No income this month.")
  defp empty_message(:expense), do: gettext("No expenses this month.")

  defp add_label(:income), do: gettext("Add income")
  defp add_label(:expense), do: gettext("Add expense")

  # --- Formatting Helpers ---

  defp format_currency(amount) do
    "#{Decimal.round(amount, 2)} €"
  end

  defp format_month(date) do
    Calendar.strftime(date, "%B %Y") |> String.capitalize()
  end

  defp format_transaction_type(%{direction: :income, income_type: type}),
    do: format_type(:income, type)

  defp format_transaction_type(%{direction: :expense, expense_type: type}),
    do: format_type(:expense, type)

  defp format_type(:income, type), do: format_income_type(type)
  defp format_type(:expense, type), do: format_expense_type(type)

  defp format_income_type(:salary), do: gettext("Salary")
  defp format_income_type(:freelance), do: gettext("Freelance")
  defp format_income_type(:rental), do: gettext("Rental")
  defp format_income_type(:bonus), do: gettext("Bonus")
  defp format_income_type(:pension), do: gettext("Pension")
  defp format_income_type(:government_aid), do: gettext("Government aid")
  defp format_income_type(:investment), do: gettext("Investment")
  defp format_income_type(:other), do: gettext("Other")
  defp format_income_type(_), do: gettext("Unknown")

  defp format_expense_type(:essential), do: gettext("Essential")
  defp format_expense_type(:pleasure), do: gettext("Pleasure")
  defp format_expense_type(:savings), do: gettext("Savings")
  defp format_expense_type(:extra), do: gettext("Extra")
  defp format_expense_type(:other), do: gettext("Other")
  defp format_expense_type(_), do: gettext("Unknown")

  # --- Calculation Helpers ---

  defp sum_amounts(transactions) do
    transactions
    |> Enum.map(& &1.amount)
    |> Enum.reduce(Decimal.new(0), &Decimal.add/2)
  end

  defp group_by_type(transactions, type_field) do
    transactions
    |> Enum.group_by(&Map.get(&1, type_field))
    |> Enum.map(fn {type, txns} -> {type, sum_amounts(txns)} end)
    |> Enum.sort_by(fn {_type, amount} -> Decimal.to_float(amount) end, :desc)
  end
end
