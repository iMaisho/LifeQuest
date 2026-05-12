defmodule LifequestWeb.FinancesLive.Index do
  use LifequestWeb, :live_view

  alias Lifequest.Finances

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <h1 class="text-4xl font-bold mb-8">{gettext("Financial information")}</h1>
      <.section title={gettext("Financial profile")} grid={false}>
        <.profile_card
          :for={{field, label, description, icon, value} <- profile_fields(@financial_profile)}
          field={field}
          label={label}
          description={description}
          icon={icon}
          value={value}
          profile={@financial_profile}
        />
      </.section>
      <.section title={gettext("Income sources")} grid={false}>
        <.type_section
          :for={{type, label, description, icon} <- income_types()}
          type={type}
          label={label}
          description={description}
          icon={icon}
          transactions={Map.get(@income_transactions, type, [])}
          direction={:income}
        />
      </.section>
      <.section title={gettext("Expenses")} grid={false}>
        <.type_section
          :for={{type, label, description, icon} <- expense_types()}
          type={type}
          label={label}
          description={description}
          icon={icon}
          transactions={Map.get(@expense_transactions, type, [])}
          direction={:expense}
        />
      </.section>
      <.section title={gettext("Category summary")} grid={false}>
        <.category_summary
          direction={:income}
          totals={@income_totals}
          types={income_types()}
        />
        <.category_summary
          direction={:expense}
          totals={@expense_totals}
          types={expense_types()}
        />
      </.section>
    </Layouts.app>
    """
  end

  # --- Components ---

  attr :title, :string, required: true
  attr :grid, :boolean, default: true
  slot :inner_block, required: true

  defp section(assigns) do
    ~H"""
    <div class="mb-12">
      <h2 class="text-2xl font-semibold mb-4">{@title}</h2>
      <div class={[
        @grid && "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4",
        not @grid && "flex flex-col gap-4"
      ]}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr :field, :atom, required: true
  attr :label, :string, required: true
  attr :description, :string, required: true
  attr :icon, :string, required: true
  attr :value, :any, required: true
  attr :profile, :any, required: true

  defp profile_card(assigns) do
    ~H"""
    <div class="card bg-base-200 shadow">
      <div class="card-body">
        <div class="flex items-center justify-between mb-2">
          <div class="flex items-center gap-3">
            <span class={"#{@icon} size-6 shrink-0"} />
            <div>
              <h3 class="font-semibold">{@label}</h3>
              <p class="text-sm opacity-70">{@description}</p>
            </div>
          </div>
          <.link navigate={profile_field_path(@profile, @field)} class="btn btn-sm btn-primary">
            <.icon
              name={if is_nil(@value), do: "hero-plus", else: "hero-pencil-square"}
              class="size-4"
            />
            {if is_nil(@value), do: gettext("Set"), else: gettext("Edit")}
          </.link>
        </div>
        <p :if={is_nil(@value)} class="text-sm opacity-50 text-center py-3">
          {gettext("Not set yet")}
        </p>
        <div :if={not is_nil(@value)} class="overflow-x-auto">
          <table class="table table-sm">
            <tbody>
              <tr>
                <td class="font-medium">{format_profile_value(@field, @value)}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  attr :type, :atom, required: true
  attr :label, :string, required: true
  attr :description, :string, required: true
  attr :icon, :string, required: true
  attr :transactions, :list, required: true
  attr :direction, :atom, required: true

  defp type_section(assigns) do
    ~H"""
    <div class="card bg-base-200 shadow">
      <div class="card-body">
        <div class="flex items-center justify-between mb-2">
          <div class="flex items-center gap-3">
            <span class={"#{@icon} size-6 shrink-0"} />
            <div>
              <h3 class="font-semibold">{@label}</h3>
              <p class="text-sm opacity-70">{@description}</p>
            </div>
          </div>
          <.link navigate={add_path(@direction, @type)} class="btn btn-sm btn-primary">
            <.icon name="hero-plus" class="size-4" />
            {gettext("Add")}
          </.link>
        </div>
        <p :if={@transactions == []} class="text-sm opacity-50 text-center py-3">
          {gettext("No transactions yet")}
        </p>
        <div :if={@transactions != []} class="overflow-x-auto">
          <table class="table table-sm">
            <thead>
              <tr>
                <th>{gettext("Label")}</th>
                <th>{gettext("Amount")}</th>
                <th>{gettext("Date")}</th>
                <th>{gettext("Account")}</th>
                <th></th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <tr :for={t <- @transactions} class={[not t.is_active && "opacity-40"]}>
                <td class="font-medium">{t.label}</td>
                <td>{Decimal.round(t.amount, 2)} €</td>
                <td>{t.date}</td>
                <td>{t.account.label}</td>
                <td>
                  <span :if={t.is_recurring} class="badge badge-sm badge-info">
                    {gettext("Recurring")}
                  </span>
                </td>
                <td>
                  <div class="flex gap-1">
                    <.link
                      navigate={~p"/transactions/#{t}/edit"}
                      class="btn btn-xs btn-ghost"
                      aria-label={gettext("Edit %{label}", label: t.label)}
                    >
                      <.icon name="hero-pencil-square" class="size-4" />
                    </.link>
                    <button
                      phx-click="delete_transaction"
                      phx-value-id={t.id}
                      data-confirm={gettext("Delete this transaction?")}
                      aria-label={gettext("Delete %{label}", label: t.label)}
                      class="btn btn-xs btn-ghost text-error"
                    >
                      <.icon name="hero-trash" class="size-4" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  attr :direction, :atom, required: true
  attr :totals, :map, required: true
  attr :types, :list, required: true

  defp category_summary(assigns) do
    ~H"""
    <div class="card bg-base-200 shadow">
      <div class="card-body">
        <h3 class="font-semibold mb-3">
          <%= if @direction == :income do %>
            {gettext("Income by category")}
          <% else %>
            {gettext("Expenses by category")}
          <% end %>
        </h3>
        <p :if={map_size(@totals) == 0} class="text-sm opacity-50 text-center py-3">
          {gettext("No transactions yet")}
        </p>
        <div :if={map_size(@totals) > 0} class="space-y-2">
          <%= for {type, label, _description, _icon} <- @types do %>
            <%= if Map.has_key?(@totals, type) do %>
              <div class="flex justify-between items-center">
                <span class={[
                  "badge badge-sm badge-outline",
                  @direction == :income && "badge-success",
                  @direction == :expense && "badge-error"
                ]}>
                  {label}
                </span>
                <span class="font-semibold text-sm">
                  {Decimal.round(Map.get(@totals, type), 2)} €
                </span>
              </div>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  # --- Mount ---

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    if connected?(socket) do
      Finances.subscribe_financial_profiles(scope)
      Finances.subscribe_transactions(scope)
    end

    financial_profile = Finances.get_financial_profile_by_user(scope)
    transactions = Finances.list_transactions(scope)

    {:ok,
     socket
     |> assign(:page_title, gettext("Financial information"))
     |> assign(:financial_profile, financial_profile)
     |> assign(:income_totals, Finances.sum_all_by_category(scope, :income))
     |> assign(:expense_totals, Finances.sum_all_by_category(scope, :expense))
     |> assign_transaction_groups(transactions)}
  end

  # --- Events ---

  @impl true
  def handle_event("delete_transaction", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    transaction = Finances.get_transaction!(scope, id)
    {:ok, _} = Finances.delete_transaction(scope, transaction)
    {:noreply, socket}
  end

  # --- PubSub ---

  @impl true
  def handle_info({type, %Finances.Transaction{}}, socket)
      when type in [:created, :updated, :deleted] do
    scope = socket.assigns.current_scope
    transactions = Finances.list_transactions(scope)

    {:noreply,
     socket
     |> assign(:income_totals, Finances.sum_all_by_category(scope, :income))
     |> assign(:expense_totals, Finances.sum_all_by_category(scope, :expense))
     |> assign_transaction_groups(transactions)}
  end

  def handle_info({type, %Finances.FinancialProfile{}}, socket)
      when type in [:created, :updated, :deleted] do
    financial_profile = Finances.get_financial_profile_by_user(socket.assigns.current_scope)
    {:noreply, assign(socket, :financial_profile, financial_profile)}
  end

  # --- Private helpers ---

  defp assign_transaction_groups(socket, transactions) do
    sorted = Enum.sort_by(transactions, & &1.date, {:desc, Date})

    income_transactions =
      sorted
      |> Enum.filter(&(&1.direction == :income))
      |> Enum.group_by(& &1.income_type)

    expense_transactions =
      sorted
      |> Enum.filter(&(&1.direction == :expense))
      |> Enum.group_by(& &1.expense_type)

    socket
    |> assign(:income_transactions, income_transactions)
    |> assign(:expense_transactions, expense_transactions)
  end

  defp add_path(:income, type),
    do: ~p"/transactions/new?direction=income&income_type=#{type}"

  defp add_path(:expense, type),
    do: ~p"/transactions/new?direction=expense&expense_type=#{type}"

  defp profile_field_path(nil, _field), do: ~p"/financial_profiles/new"

  defp profile_field_path(profile, field),
    do: ~p"/financial_profiles/#{profile}/edit?field=#{field}"

  defp format_profile_value(:employment_status, value), do: format_employment_status(value)
  defp format_profile_value(_field, value), do: "#{Decimal.round(value, 2)} €"

  defp format_employment_status(:cdi), do: gettext("Permanent contract")
  defp format_employment_status(:cdd), do: gettext("Fixed-term contract")
  defp format_employment_status(:freelance), do: gettext("Freelance")
  defp format_employment_status(:business_owner), do: gettext("Business owner")
  defp format_employment_status(:unemployed), do: gettext("Unemployed")
  defp format_employment_status(:retired), do: gettext("Retired")
  defp format_employment_status(_), do: gettext("Unknown")

  # --- Data ---

  defp profile_fields(nil) do
    [
      {:current_savings, gettext("Current savings"), gettext("Total available savings"),
       "hero-banknotes", nil},
      {:current_debts, gettext("Current debts"), gettext("Outstanding debts"),
       "hero-exclamation-triangle", nil},
      {:monthly_debt_payment, gettext("Monthly debt payment"),
       gettext("Monthly repayment amount"), "hero-arrow-uturn-left", nil},
      {:net_worth, gettext("Net worth"), gettext("Total estimated assets"), "hero-scale", nil},
      {:employment_status, gettext("Employment status"),
       gettext("Current professional situation"), "hero-briefcase", nil}
    ]
  end

  defp profile_fields(profile) do
    [
      {:current_savings, gettext("Current savings"), gettext("Total available savings"),
       "hero-banknotes", profile.current_savings},
      {:current_debts, gettext("Current debts"), gettext("Outstanding debts"),
       "hero-exclamation-triangle", profile.current_debts},
      {:monthly_debt_payment, gettext("Monthly debt payment"),
       gettext("Monthly repayment amount"), "hero-arrow-uturn-left",
       profile.monthly_debt_payment},
      {:net_worth, gettext("Net worth"), gettext("Total estimated assets"), "hero-scale",
       profile.net_worth},
      {:employment_status, gettext("Employment status"),
       gettext("Current professional situation"), "hero-briefcase", profile.employment_status}
    ]
  end

  defp income_types do
    [
      {:salary, gettext("Salary"), gettext("Monthly wages, net income"), "hero-banknotes"},
      {:freelance, gettext("Freelance"), gettext("Independent work, contracts"),
       "hero-briefcase"},
      {:rental, gettext("Rental"), gettext("Property rental income"), "hero-home-modern"},
      {:bonus, gettext("Bonus"), gettext("Annual bonuses, profit sharing"), "hero-gift"},
      {:pension, gettext("Pension"), gettext("Retirement, alimony received"), "hero-heart"},
      {:government_aid, gettext("Government aid"), gettext("APL, RSA, benefits"),
       "hero-shield-check"},
      {:investment, gettext("Investment"), gettext("Dividends, interest"), "hero-chart-bar"},
      {:other, gettext("Other income"), gettext("Miscellaneous income"), "hero-plus-circle"}
    ]
  end

  defp expense_types do
    [
      {:essential, gettext("Essential"), gettext("Rent, insurance, subscriptions"), "hero-home"},
      {:pleasure, gettext("Pleasure"), gettext("Dining out, entertainment, shopping"),
       "hero-face-smile"},
      {:savings, gettext("Savings"), gettext("Automatic transfers to savings"),
       "hero-arrow-trending-up"},
      {:extra, gettext("Extra"), gettext("Unexpected expenses"), "hero-exclamation-triangle"},
      {:other, gettext("Other expenses"), gettext("Miscellaneous expenses"), "hero-plus-circle"}
    ]
  end
end
