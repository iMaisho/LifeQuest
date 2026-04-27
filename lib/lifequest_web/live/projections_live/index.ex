defmodule LifequestWeb.ProjectionsLive.Index do
  use LifequestWeb, :live_view

  alias Lifequest.Finances

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <h1 class="text-4xl font-bold mb-8">{gettext("Projections")}</h1>

      <div class="card bg-base-200 shadow mb-6">
        <div class="card-body">
          <.form for={@form} phx-submit="calculate">
            <.input
              field={@form[:target_date]}
              type="date"
              label={gettext("Project my finances to")}
              min={Date.to_iso8601(Date.utc_today())}
            />
            <div class="card-actions justify-end mt-2">
              <button type="submit" class="btn btn-primary">
                <.icon name="hero-calculator" class="size-4" />
                {gettext("Calculate")}
              </button>
            </div>
          </.form>
        </div>
      </div>

      <%= if @projection do %>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <div class="card bg-base-200 shadow">
            <div class="card-body">
              <p class="text-sm opacity-60">{gettext("Projected savings")}</p>
              <p class="text-3xl font-bold">{fmt(@projection.projected_savings)} €</p>
              <p class="text-xs opacity-40">
                {gettext("today")}: {fmt(@projection.current_savings)} €
              </p>
            </div>
          </div>
          <div class="card bg-base-200 shadow">
            <div class="card-body">
              <p class="text-sm opacity-60">{gettext("Remaining debts")}</p>
              <p class="text-3xl font-bold">{fmt(@projection.projected_debts)} €</p>
              <p class="text-xs opacity-40">
                {gettext("today")}: {fmt(@projection.current_debts)} €
              </p>
            </div>
          </div>
          <div class="card bg-base-200 shadow">
            <div class="card-body">
              <p class="text-sm opacity-60">{gettext("Monthly net change")}</p>
              <p class={[
                "text-3xl font-bold",
                decimal_gte_zero?(@projection.monthly_net_after_debt) && "text-success",
                not decimal_gte_zero?(@projection.monthly_net_after_debt) && "text-error"
              ]}>
                {fmt(@projection.monthly_net_after_debt)} €
              </p>
              <p class="text-xs opacity-40">{gettext("after debt repayment")}</p>
            </div>
          </div>
        </div>

        <div class="card bg-base-200 shadow mb-4">
          <div class="card-body">
            <h2 class="font-semibold mb-2">{gettext("Monthly breakdown")}</h2>
            <table class="table table-sm">
              <tbody>
                <tr>
                  <td class="opacity-60">{gettext("Recurring income")}</td>
                  <td class="font-medium text-success text-right">
                    +{fmt(@projection.monthly_income)} €
                  </td>
                </tr>
                <tr>
                  <td class="opacity-60">{gettext("Recurring expenses")}</td>
                  <td class="font-medium text-error text-right">
                    -{fmt(@projection.monthly_expenses)} €
                  </td>
                </tr>
                <tr>
                  <td class="opacity-60">{gettext("Debt repayment")}</td>
                  <td class="font-medium text-warning text-right">
                    -{fmt(@projection.monthly_debt_payment)} €
                  </td>
                </tr>
                <tr class="border-t border-base-300">
                  <td class="font-semibold">{gettext("Net")}</td>
                  <td class={[
                    "font-bold text-right",
                    decimal_gte_zero?(@projection.monthly_net_after_debt) && "text-success",
                    not decimal_gte_zero?(@projection.monthly_net_after_debt) && "text-error"
                  ]}>
                    {fmt(@projection.monthly_net_after_debt)} €
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <p class="text-sm opacity-40 text-center">
          {gettext("Projection over %{months} months", months: @projection.months)}
        </p>
      <% end %>

      <%= if @no_profile do %>
        <div class="alert alert-warning">
          <.icon name="hero-exclamation-triangle" class="size-5" />
          <span>
            {gettext("Please set up your")}
            <.link navigate={~p"/finances"} class="link">{gettext("financial profile")}</.link>
            {gettext("before running projections.")}
          </span>
        </div>
      <% end %>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    default_date = Date.utc_today() |> Date.add(365) |> Date.to_iso8601()

    {:ok,
     socket
     |> assign(:page_title, gettext("Projections"))
     |> assign(:form, to_form(%{"target_date" => default_date}, as: :projection))
     |> assign(:projection, nil)
     |> assign(:no_profile, false)}
  end

  @impl true
  def handle_event("calculate", %{"projection" => %{"target_date" => date_str}}, socket) do
    with {:ok, date} <- Date.from_iso8601(date_str),
         true <- Date.compare(date, Date.utc_today()) == :gt,
         {:ok, projection} <- Finances.project_savings(socket.assigns.current_scope, date) do
      {:noreply,
       socket
       |> assign(:projection, projection)
       |> assign(:no_profile, false)}
    else
      {:error, :no_profile} ->
        {:noreply, assign(socket, :no_profile, true)}

      _ ->
        {:noreply, put_flash(socket, :error, gettext("Please enter a valid future date."))}
    end
  end

  defp fmt(decimal), do: Decimal.round(decimal, 2)

  defp decimal_gte_zero?(d), do: Decimal.compare(d, Decimal.new(0)) in [:gt, :eq]
end
