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
          title={gettext("Income by type")}
          slices={@income_slices}
          empty_label={gettext("No income")}
        />
        <.donut_chart
          title={gettext("Expenses by type")}
          slices={@expense_slices}
          empty_label={gettext("No expenses")}
        />
      </div>

      <div class="card bg-base-200 shadow mb-12">
        <div class="card-body">
          <h2 class="card-title mb-4">{gettext("Monthly balance")}</h2>
          <div class="flex flex-col gap-2">
            <div class="flex justify-between items-center">
              <span class="text-success font-medium">{gettext("Total income")}</span>
              <span class="text-success font-semibold">{format_currency(@total_income)}</span>
            </div>
            <div class="flex justify-between items-center">
              <span class="text-error font-medium">{gettext("Total expenses")}</span>
              <span class="text-error font-semibold">{format_currency(@total_expense)}</span>
            </div>
            <div class="divider my-1"></div>
            <div class="flex justify-between items-center">
              <span class="font-bold text-lg">{gettext("Balance")}</span>
              <span class={[
                "font-bold text-lg",
                Decimal.compare(Decimal.sub(@total_income, @total_expense), Decimal.new(0)) in [
                  :gt,
                  :eq
                ] && "text-success",
                Decimal.compare(Decimal.sub(@total_income, @total_expense), Decimal.new(0)) == :lt &&
                  "text-error"
              ]}>
                {format_currency(Decimal.sub(@total_income, @total_expense))}
              </span>
            </div>
          </div>
        </div>
      </div>

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

      <.top_expense_categories top_categories={@top_expense_categories} />
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

  defp top_expense_categories(assigns) do
    ~H"""
    <div :if={@top_categories != []} class="mb-12">
      <div class="card bg-base-200 shadow">
        <div class="card-body">
          <h2 class="card-title mb-4">{gettext("Top expense categories")}</h2>
          <div class="space-y-3">
            <div
              :for={{category, total} <- @top_categories}
              class="flex justify-between items-center"
            >
              <span class="badge badge-error badge-outline">
                {format_expense_type(category)}
              </span>
              <span class="font-semibold">{format_currency(total)}</span>
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

  @circumference 251.2

  attr :title, :string, required: true
  attr :slices, :list, required: true
  attr :empty_label, :string, required: true

  defp donut_chart(assigns) do
    assigns = assign(assigns, :circumference, @circumference)

    ~H"""
    <div class="card bg-base-200 shadow">
      <div class="card-body items-center">
        <h2 class="card-title">{@title}</h2>
        <%= if @slices == [] do %>
          <p class="text-sm opacity-60 mt-4">{@empty_label}</p>
        <% else %>
          <svg viewBox="0 0 100 100" class="w-48 h-48 -rotate-90">
            <%= for {slice, offset} <- compute_arc_offsets(@slices, @circumference) do %>
              <circle
                cx="50"
                cy="50"
                r="40"
                fill="none"
                stroke={slice.color}
                stroke-width="20"
                stroke-dasharray={"#{slice.arc_length} #{@circumference}"}
                stroke-dashoffset={offset}
              />
            <% end %>
          </svg>
          <div class="flex flex-wrap justify-center gap-x-4 gap-y-1 mt-2">
            <div :for={slice <- @slices} class="flex items-center gap-1 text-xs">
              <span
                class="inline-block w-3 h-3 rounded-full shrink-0"
                style={"background-color: #{slice.color};"}
              >
              </span>
              <span>{slice.label}</span>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # Computes {slice_with_arc_length, stroke_dashoffset} pairs for SVG rendering.
  # Each slice starts where the previous ended; offset walks backward from circumference.
  defp compute_arc_offsets(slices, circumference) do
    total =
      slices
      |> Enum.map(&Decimal.to_float(&1.value))
      |> Enum.sum()

    slices_with_arc =
      Enum.map(slices, fn slice ->
        arc = Decimal.to_float(slice.value) / total * circumference
        Map.put(slice, :arc_length, arc)
      end)

    {pairs, _} =
      Enum.map_reduce(slices_with_arc, 0.0, fn slice, cumulative ->
        offset = circumference - cumulative

        {
          {slice, offset},
          cumulative + slice.arc_length
        }
      end)

    pairs
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

    top_expense_categories =
      Finances.sum_all_by_category(scope, :expense)
      |> Enum.sort_by(fn {_cat, amount} -> Decimal.to_float(amount) end, :desc)
      |> Enum.take(5)

    income_slices = build_income_slices(Finances.sum_all_by_category(scope, :income))
    expense_slices = build_expense_slices(Finances.sum_all_by_category(scope, :expense))

    socket
    |> assign(:incomes, incomes)
    |> assign(:expenses, expenses)
    |> assign(:pending_incomes, pending_incomes)
    |> assign(:pending_expenses, pending_expenses)
    |> assign(:total_income, sum_amounts(incomes))
    |> assign(:total_expense, sum_amounts(expenses))
    |> assign(:income_by_type, group_by_type(incomes, :income_type))
    |> assign(:expense_by_type, group_by_type(expenses, :expense_type))
    |> assign(:top_expense_categories, top_expense_categories)
    |> assign(:income_slices, income_slices)
    |> assign(:expense_slices, expense_slices)
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

  # --- Slice Builders ---

  @income_colors %{
    salary: "#22c55e",
    freelance: "#16a34a",
    rental: "#15803d",
    bonus: "#4ade80",
    pension: "#86efac",
    government_aid: "#bbf7d0",
    investment: "#34d399",
    other: "#6ee7b7"
  }

  @expense_colors %{
    essential: "#ef4444",
    pleasure: "#f97316",
    savings: "#3b82f6",
    extra: "#eab308",
    other: "#94a3b8"
  }

  defp build_income_slices(category_map) do
    Enum.map(category_map, fn {type, value} ->
      %{
        label: format_income_type(type),
        value: value,
        color: Map.get(@income_colors, type, "#6ee7b7")
      }
    end)
  end

  defp build_expense_slices(category_map) do
    Enum.map(category_map, fn {type, value} ->
      %{
        label: format_expense_type(type),
        value: value,
        color: Map.get(@expense_colors, type, "#94a3b8")
      }
    end)
  end

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
