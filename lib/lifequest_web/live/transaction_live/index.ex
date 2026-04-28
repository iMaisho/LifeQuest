defmodule LifequestWeb.TransactionLive.Index do
  use LifequestWeb, :live_view

  alias Lifequest.Finances

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Transactions")}
        <:actions>
          <.button variant="primary" navigate={~p"/transactions/new"}>
            <.icon name="hero-plus" /> {gettext("New Transaction")}
          </.button>
        </:actions>
      </.header>

      <div class="mb-6 flex flex-wrap gap-3 items-center">
        <div class="flex gap-2">
          <button
            phx-click="filter_direction"
            phx-value-direction="all"
            class={[
              "btn btn-sm",
              @filter_direction == "all" && "btn-primary",
              @filter_direction != "all" && "btn-outline"
            ]}
          >
            {gettext("All")}
          </button>
          <button
            phx-click="filter_direction"
            phx-value-direction="income"
            class={[
              "btn btn-sm",
              @filter_direction == "income" && "btn-success",
              @filter_direction != "income" && "btn-outline"
            ]}
          >
            {gettext("Income")}
          </button>
          <button
            phx-click="filter_direction"
            phx-value-direction="expense"
            class={[
              "btn btn-sm",
              @filter_direction == "expense" && "btn-error",
              @filter_direction != "expense" && "btn-outline"
            ]}
          >
            {gettext("Expense")}
          </button>
        </div>

        <select
          :if={@filter_direction != "all"}
          phx-change="filter_category"
          class="select select-sm select-bordered"
          name="category"
        >
          <option value="">{gettext("All categories")}</option>
          <%= for {value, label} <- category_options(@filter_direction) do %>
            <option value={value} selected={@filter_category == value}>{label}</option>
          <% end %>
        </select>
      </div>

      <.table
        id="transactions"
        rows={@streams.transactions}
        row_click={fn {_id, transaction} -> JS.navigate(~p"/transactions/#{transaction}") end}
      >
        <:col :let={{_id, transaction}} label={gettext("Label")}>{transaction.label}</:col>
        <:col :let={{_id, transaction}} label={gettext("Category")}>
          <.category_badge transaction={transaction} />
        </:col>
        <:col :let={{_id, transaction}} label={gettext("Amount")}>
          <span class={[
            "font-semibold",
            transaction.direction == :income && "text-success",
            transaction.direction == :expense && "text-error"
          ]}>
            {Decimal.round(transaction.amount, 2)} €
          </span>
        </:col>
        <:col :let={{_id, transaction}} label={gettext("Date")}>{transaction.date}</:col>
        <:col :let={{_id, transaction}} label={gettext("Recurring")}>
          <span :if={transaction.is_recurring} class="badge badge-sm badge-info">
            {gettext("Recurring")}
          </span>
        </:col>
        <:action :let={{_id, transaction}}>
          <.link navigate={~p"/transactions/#{transaction}/edit"}>{gettext("Edit")}</.link>
        </:action>
        <:action :let={{id, transaction}}>
          <.link
            phx-click={JS.push("delete", value: %{id: transaction.id}) |> hide("##{id}")}
            data-confirm={gettext("Are you sure?")}
          >
            {gettext("Delete")}
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  attr :transaction, :map, required: true

  defp category_badge(assigns) do
    ~H"""
    <%= if @transaction.direction == :income do %>
      <span class="badge badge-sm badge-success badge-outline">
        {format_income_type(@transaction.income_type)}
      </span>
    <% else %>
      <span class="badge badge-sm badge-error badge-outline">
        {format_expense_type(@transaction.expense_type)}
      </span>
    <% end %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Finances.subscribe_transactions(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, gettext("Transactions"))
     |> assign(:filter_direction, "all")
     |> assign(:filter_category, "")
     |> stream(:transactions, Finances.list_transactions(socket.assigns.current_scope))}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    direction = params["direction"] || "all"
    category = params["category"] || ""

    transactions = load_filtered(socket.assigns.current_scope, direction, category)

    {:noreply,
     socket
     |> assign(:filter_direction, direction)
     |> assign(:filter_category, category)
     |> stream(:transactions, transactions, reset: true)}
  end

  @impl true
  def handle_event("filter_direction", %{"direction" => direction}, socket) do
    {:noreply, push_patch(socket, to: ~p"/transactions?direction=#{direction}")}
  end

  def handle_event("filter_category", %{"category" => category}, socket) do
    direction = socket.assigns.filter_direction

    {:noreply,
     push_patch(socket, to: ~p"/transactions?direction=#{direction}&category=#{category}")}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Finances.get_transaction!(socket.assigns.current_scope, id)
    {:ok, _} = Finances.delete_transaction(socket.assigns.current_scope, transaction)

    {:noreply, stream_delete(socket, :transactions, transaction)}
  end

  @impl true
  def handle_info({type, %Lifequest.Finances.Transaction{}}, socket)
      when type in [:created, :updated, :deleted] do
    direction = socket.assigns.filter_direction
    category = socket.assigns.filter_category
    transactions = load_filtered(socket.assigns.current_scope, direction, category)

    {:noreply, stream(socket, :transactions, transactions, reset: true)}
  end

  # --- Private helpers ---

  defp load_filtered(scope, "all", _category) do
    Finances.list_transactions(scope)
  end

  defp load_filtered(scope, direction, "") do
    dir = String.to_existing_atom(direction)
    Finances.list_transactions(scope) |> Enum.filter(&(&1.direction == dir))
  end

  defp load_filtered(scope, direction, category) when category != "" do
    dir = String.to_existing_atom(direction)

    category_atom =
      try do
        String.to_existing_atom(category)
      rescue
        ArgumentError -> nil
      end

    if category_atom do
      Finances.list_transactions_by_category(scope, dir, category_atom)
    else
      Finances.list_transactions(scope) |> Enum.filter(&(&1.direction == dir))
    end
  end

  defp category_options("income") do
    [
      {"salary", gettext("Salary")},
      {"freelance", gettext("Freelance")},
      {"rental", gettext("Rental")},
      {"bonus", gettext("Bonus")},
      {"pension", gettext("Pension")},
      {"government_aid", gettext("Government aid")},
      {"investment", gettext("Investment")},
      {"other", gettext("Other")}
    ]
  end

  defp category_options("expense") do
    [
      {"essential", gettext("Essential")},
      {"pleasure", gettext("Pleasure")},
      {"savings", gettext("Savings")},
      {"extra", gettext("Extra")},
      {"other", gettext("Other")}
    ]
  end

  defp category_options(_), do: []

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
end
