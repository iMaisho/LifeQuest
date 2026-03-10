defmodule LifequestWeb.FinancesLive.Index do
  use LifequestWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <h1 class="text-4xl font-bold mb-8">{gettext("Financial information")}</h1>
      <.section title={gettext("Financial profile")}>
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
      <.section title={gettext("Income sources")}>
        <.type_card
          :for={{type, label, description, icon} <- income_types()}
          label={label}
          description={description}
          href={~p"/transactions/new?direction=income&income_type=#{type}"}
          icon={icon}
        />
      </.section>
      <.section title={gettext("Expenses")}>
        <.type_card
          :for={{type, label, description, icon} <- expense_types()}
          label={label}
          description={description}
          href={~p"/transactions/new?direction=expense&expense_type=#{type}"}
          icon={icon}
        />
      </.section>
    </Layouts.app>
    """
  end

  # --- Components ---

  defp section(assigns) do
    ~H"""
    <div class="mb-12">
      <h2 class="text-2xl font-semibold mb-4">{@title}</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr :label, :string, required: true
  attr :description, :string, required: true
  attr :href, :string, required: true
  attr :icon, :string, required: true

  defp type_card(assigns) do
    ~H"""
    <.link
      navigate={@href}
      class="card bg-base-200 shadow hover:shadow-lg hover:bg-base-300 transition-all cursor-pointer"
    >
      <div class="card-body flex flex-row items-center gap-4">
        <span class={"#{@icon} size-8 shrink-0"} />
        <div>
          <h3 class="card-title text-base">{@label}</h3>
          <p class="text-sm opacity-70">{@description}</p>
        </div>
      </div>
    </.link>
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
    <.link
      navigate={profile_field_path(@profile, @field)}
      class="card bg-base-200 shadow hover:shadow-lg hover:bg-base-300 transition-all cursor-pointer"
    >
      <div class="card-body flex flex-row items-center gap-4">
        <span class={"#{@icon} size-8 shrink-0"} />
        <div class="flex-1">
          <h3 class="card-title text-base">{@label}</h3>
          <p class="text-sm opacity-70">{@description}</p>
        </div>
        
        <div class="text-right">
          <span :if={@value} class="font-semibold">{format_profile_value(@field, @value)}</span>
          <span :if={is_nil(@value)} class="badge badge-warning badge-sm">{gettext("Not set")}</span>
        </div>
      </div>
    </.link>
    """
  end

  # --- Mount ---

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    financial_profile = Lifequest.Finances.get_financial_profile_by_user(scope)

    {:ok,
     socket
     |> assign(:page_title, gettext("Financial information"))
     |> assign(:financial_profile, financial_profile)}
  end

  # --- Profile Fields ---

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

  # --- Helpers ---

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
