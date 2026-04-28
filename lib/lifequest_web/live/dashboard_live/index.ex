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

  # --- Components ---

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
    <div class="alert alert-info mb-8">
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
    total = Enum.reduce(assigns.slices, Decimal.new(0), &Decimal.add(&2, &1.value))

    assigns =
      assigns
      |> assign(:circumference, @circumference)
      |> assign(:donut_total, total)

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
            <text
              x="50"
              y="50"
              text-anchor="middle"
              dominant-baseline="middle"
              transform="rotate(90, 50, 50)"
              font-size="7"
              font-weight="bold"
              class="fill-current"
            >
              {format_currency(@donut_total)}
            </text>
          </svg>
          <div class="w-full flex flex-col gap-1 mt-3">
            <div :for={slice <- @slices} class="flex items-center gap-2 text-sm">
              <span
                class="inline-block w-3 h-3 rounded-sm shrink-0"
                style={"background-color: #{slice.color};"}
              >
              </span>
              <span class="flex-1">{slice.label}</span>
              <span class="font-semibold">{format_currency(slice.value)}</span>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # Computes {slice_with_arc_length, stroke_dashoffset} pairs for SVG rendering.
  # offset = arc_length + C - cumulative positions each slice right after the previous.
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
        offset = slice.arc_length + circumference - cumulative

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

    socket
    |> assign(:incomes, incomes)
    |> assign(:expenses, expenses)
    |> assign(:pending_incomes, pending_incomes)
    |> assign(:pending_expenses, pending_expenses)
    |> assign(:income_slices, build_income_slices(group_amounts_by_type(incomes, :income_type)))
    |> assign(
      :expense_slices,
      build_expense_slices(group_amounts_by_type(expenses, :expense_type))
    )
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

  # --- Labels ---

  defp pending_title(:income), do: gettext("Recurring income to validate")
  defp pending_title(:expense), do: gettext("Recurring expenses to validate")

  defp empty_message(:income), do: gettext("No income this month.")
  defp empty_message(:expense), do: gettext("No expenses this month.")

  defp add_label(:income), do: gettext("Add income")
  defp add_label(:expense), do: gettext("Add expense")

  # --- Formatting ---

  defp format_currency(amount) do
    "#{Decimal.round(amount, 2)} €"
  end

  defp format_month(date) do
    Calendar.strftime(date, "%B %Y") |> String.capitalize()
  end

  defp format_transaction_type(%{direction: :income, income_type: type}),
    do: format_income_type(type)

  defp format_transaction_type(%{direction: :expense, expense_type: type}),
    do: format_expense_type(type)

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
    Enum.reduce(transactions, Decimal.new(0), &Decimal.add(&2, &1.amount))
  end

  defp group_amounts_by_type(transactions, type_field) do
    transactions
    |> Enum.group_by(&Map.get(&1, type_field))
    |> Enum.map(fn {type, txns} -> {type, sum_amounts(txns)} end)
    |> Enum.sort_by(fn {_type, amount} -> Decimal.to_float(amount) end, :desc)
  end
end
