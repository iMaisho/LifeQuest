defmodule LifequestWeb.GoalsLive.Index do
  use LifequestWeb, :live_view

  alias Lifequest.Finances

  @safe_rate 0.03
  @risky_rates %{pessimistic: -0.15, expected: 0.08, optimistic: 0.20}
  @safety_net_months 3

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <h1 class="text-4xl font-bold mb-2">{gettext("Goals")}</h1>
      <p class="text-sm opacity-70 mb-8">
        {gettext("Find out whether your financial goal is realistic and how to reach it.")}
      </p>

      <div :if={@no_profile} class="alert alert-warning">
        <.icon name="hero-exclamation-triangle" class="size-5" />
        <span>
          {gettext("Please set up your")}
          <.link navigate={~p"/finances"} class="link">{gettext("financial profile")}</.link>
          {gettext("before evaluating a goal.")}
        </span>
      </div>

      <div :if={not @no_profile} class="space-y-6">
        <%!-- Goal form --%>
        <div class="card bg-base-200 shadow">
          <div class="card-body">
            <h2 class="font-semibold mb-3">{gettext("Define your goal")}</h2>
            <.form for={@form} phx-submit="evaluate" class="space-y-3">
              <.input
                field={@form[:target_amount]}
                type="number"
                label={gettext("Amount needed (€)")}
                min="1"
                step="100"
                placeholder="50000"
              />
              <.input
                field={@form[:target_date]}
                type="date"
                label={gettext("Target date")}
                min={Date.to_iso8601(Date.utc_today() |> Date.add(30))}
              />
              <div class="card-actions justify-end mt-2">
                <button type="submit" class="btn btn-primary">
                  <.icon name="hero-calculator" class="size-4" />
                  {gettext("Evaluate")}
                </button>
              </div>
            </.form>
          </div>
        </div>

        <%!-- Financial context --%>
        <div class="card bg-base-200 shadow">
          <div class="card-body">
            <h2 class="font-semibold mb-4">{gettext("Your financial situation")}</h2>
            <div class="space-y-2 text-sm">
              <div class="flex justify-between">
                <span class="opacity-60">{gettext("Current savings")}</span>
                <span class="font-medium">{fmt_d(@context.current_savings)} €</span>
              </div>
              <div class="flex justify-between">
                <span class="opacity-60">{gettext("Monthly income")}</span>
                <span class="font-medium text-success">{fmt_d(@context.monthly_income)} €</span>
              </div>
              <div class="flex justify-between">
                <span class="opacity-60">
                  {gettext("Safety net (%{n} months income)", n: @safety_net_months)}
                </span>
                <span class={[
                  "font-medium",
                  not enough_safety_net?(@context) && "text-error",
                  enough_safety_net?(@context) && "text-base-content"
                ]}>
                  {fmt_d(safety_net(@context))} €
                </span>
              </div>
              <div class="flex justify-between">
                <span class="opacity-60">{gettext("Monthly surplus")}</span>
                <span class={[
                  "font-medium",
                  not positive_surplus?(@context) && "text-error",
                  positive_surplus?(@context) && "text-success"
                ]}>
                  {fmt_d(@context.monthly_net_after_debt)} €
                </span>
              </div>
              <div class="flex justify-between border-t border-base-300 pt-2 mt-1 font-semibold">
                <span>{gettext("Investable capital")}</span>
                <span>{fmt_d(investable_capital(@context))} €</span>
              </div>
            </div>
          </div>
        </div>

        <%!-- Evaluation result --%>
        <%= if @evaluation do %>
          <.evaluation_result evaluation={@evaluation} />
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  attr :evaluation, :map, required: true

  defp evaluation_result(assigns) do
    ~H"""
    <%= case @evaluation.status do %>
      <% :safe -> %>
        <div class="card bg-success/10 border border-success/30 shadow">
          <div class="card-body">
            <div class="flex items-center gap-2 mb-2">
              <.icon name="hero-check-circle" class="size-6 text-success" />
              <h2 class="font-bold text-lg text-success">{gettext("Goal reachable")}</h2>
            </div>
            <p class="text-sm opacity-70 mb-4">
              {gettext(
                "With the Safe Savings Account (+3%/year), you can reach your goal without taking any risks."
              )}
            </p>
            <.simulation_summary evaluation={@evaluation} />
            <div class="flex justify-between font-bold text-lg border-t border-base-300 pt-3 mt-1">
              <span>{gettext("Projected value (safe)")}</span>
              <span class="text-success">{fmt(@evaluation.safe_final)} €</span>
            </div>
          </div>
        </div>
      <% :risky_expected -> %>
        <div class="card bg-warning/10 border border-warning/30 shadow">
          <div class="card-body">
            <div class="flex items-center gap-2 mb-2">
              <.icon name="hero-exclamation-triangle" class="size-6 text-warning" />
              <h2 class="font-bold text-lg">{gettext("Goal reachable, but with risk")}</h2>
            </div>
            <p class="text-sm opacity-70 mb-4">
              {gettext(
                "The safe placement falls short. The Dynamic Portfolio (expected +8%/year) can reach your goal, but returns are not guaranteed."
              )}
            </p>
            <.simulation_summary evaluation={@evaluation} />
            <.risky_scenarios evaluation={@evaluation} />
          </div>
        </div>
      <% :risky_optimistic_only -> %>
        <div class="card bg-error/10 border border-error/30 shadow">
          <div class="card-body">
            <div class="flex items-center gap-2 mb-2">
              <.icon name="hero-exclamation-triangle" class="size-6 text-error" />
              <h2 class="font-bold text-lg text-error">
                {gettext("Goal reachable only in the best case")}
              </h2>
            </div>
            <p class="text-sm opacity-70 mb-4">
              {gettext(
                "Only the optimistic scenario (+20%/year) reaches your goal. This represents significant risk."
              )}
            </p>
            <.simulation_summary evaluation={@evaluation} />
            <.risky_scenarios evaluation={@evaluation} />
          </div>
        </div>
      <% :unreachable -> %>
        <div class="card bg-error/10 border border-error/30 shadow">
          <div class="card-body">
            <div class="flex items-center gap-2 mb-2">
              <.icon name="hero-x-circle" class="size-6 text-error" />
              <h2 class="font-bold text-lg text-error">{gettext("Goal not realistic")}</h2>
            </div>
            <p class="text-sm opacity-70 mb-4">
              {gettext(
                "Even the most optimistic investment scenario cannot reach your goal by this date."
              )}
            </p>
            <.simulation_summary evaluation={@evaluation} />
            <.risky_scenarios evaluation={@evaluation} />
            <div class="border-t border-base-300 pt-3 mt-1">
              <p class="text-sm opacity-60 mb-1">
                {gettext("To reach your goal with the safe placement, you would need:")}
              </p>
              <p class="text-xl font-bold text-error">
                +{fmt(@evaluation.additional_monthly_needed)} € / {gettext("month")}
              </p>
            </div>
          </div>
        </div>
    <% end %>
    """
  end

  attr :evaluation, :map, required: true

  defp simulation_summary(assigns) do
    ~H"""
    <div class="grid grid-cols-3 gap-2 mb-4 text-sm">
      <div class="bg-base-200 rounded-lg p-2 text-center">
        <p class="text-xs opacity-60 mb-1">{gettext("Initial capital")}</p>
        <p class="font-semibold">{fmt(@evaluation.investable_capital)} €</p>
      </div>
      <div class="bg-base-200 rounded-lg p-2 text-center">
        <p class="text-xs opacity-60 mb-1">{gettext("Monthly contribution")}</p>
        <p class="font-semibold">{fmt(@evaluation.monthly_surplus)} €</p>
      </div>
      <div class="bg-base-200 rounded-lg p-2 text-center">
        <p class="text-xs opacity-60 mb-1">{gettext("Duration")}</p>
        <p class="font-semibold">{@evaluation.months} {gettext("months")}</p>
      </div>
    </div>
    """
  end

  attr :evaluation, :map, required: true

  defp risky_scenarios(assigns) do
    ~H"""
    <div class="grid grid-cols-3 gap-2 mb-4">
      <div class="rounded-lg bg-error/20 p-3 text-center">
        <p class="text-xs opacity-60 mb-1">{gettext("Pessimistic")}</p>
        <p class="font-bold text-sm text-error">{fmt(@evaluation.pessimistic)} €</p>
      </div>
      <div class="rounded-lg bg-primary/10 p-3 text-center">
        <p class="text-xs opacity-60 mb-1">{gettext("Expected")}</p>
        <p class="font-bold text-sm text-primary">{fmt(@evaluation.expected)} €</p>
      </div>
      <div class="rounded-lg bg-success/10 p-3 text-center">
        <p class="text-xs opacity-60 mb-1">{gettext("Optimistic")}</p>
        <p class="font-bold text-sm text-success">{fmt(@evaluation.optimistic)} €</p>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    default_date = Date.utc_today() |> Date.add(365 * 5) |> Date.to_iso8601()

    {:ok,
     socket
     |> assign(:page_title, gettext("Goals"))
     |> assign(:safety_net_months, @safety_net_months)
     |> assign(:form, to_form(%{"target_amount" => "", "target_date" => default_date}, as: :goal))
     |> assign(:evaluation, nil)
     |> load_context(scope)}
  end

  @impl true
  def handle_event("evaluate", %{"goal" => params}, socket) do
    with {:ok, amount} <- parse_amount(params["target_amount"]),
         {:ok, date} <- Date.from_iso8601(params["target_date"]),
         true <- Date.compare(date, Date.utc_today()) == :gt do
      evaluation = build_evaluation(socket.assigns.context, amount, date)

      {:noreply,
       socket
       |> assign(:form, to_form(params, as: :goal))
       |> assign(:evaluation, evaluation)}
    else
      _ ->
        {:noreply,
         put_flash(socket, :error, gettext("Please enter a valid amount and a future date."))}
    end
  end

  defp load_context(socket, scope) do
    # project_savings with today returns current state + monthly figures with 0-month simulation
    case Finances.project_savings(scope, Date.utc_today()) do
      {:ok, context} ->
        socket |> assign(:no_profile, false) |> assign(:context, context)

      {:error, :no_profile} ->
        socket |> assign(:no_profile, true) |> assign(:context, nil)
    end
  end

  defp build_evaluation(context, target_amount, target_date) do
    months = max(1, months_between(Date.utc_today(), target_date))
    years = months / 12
    investable = investable_capital_float(context)
    surplus = monthly_surplus_float(context)
    safe_final = future_value(investable, surplus, @safe_rate, years)

    base = %{
      investable_capital: investable,
      monthly_surplus: surplus,
      months: months,
      safe_final: safe_final
    }

    if safe_final >= target_amount do
      Map.put(base, :status, :safe)
    else
      pessimistic = future_value(investable, surplus, @risky_rates.pessimistic, years)
      expected = future_value(investable, surplus, @risky_rates.expected, years)
      optimistic = future_value(investable, surplus, @risky_rates.optimistic, years)

      status =
        cond do
          expected >= target_amount -> :risky_expected
          optimistic >= target_amount -> :risky_optimistic_only
          true -> :unreachable
        end

      required = required_monthly(target_amount, investable, @safe_rate, years)

      base
      |> Map.merge(%{
        status: status,
        pessimistic: pessimistic,
        expected: expected,
        optimistic: optimistic,
        additional_monthly_needed: max(0.0, required - surplus)
      })
    end
  end

  defp safety_net(context) do
    Decimal.mult(context.monthly_income, Decimal.new(@safety_net_months))
  end

  defp investable_capital(context) do
    net = Decimal.sub(context.current_savings, safety_net(context))
    if Decimal.compare(net, Decimal.new(0)) == :lt, do: Decimal.new(0), else: net
  end

  defp investable_capital_float(context) do
    context |> investable_capital() |> Decimal.to_float()
  end

  defp monthly_surplus_float(context) do
    max(0.0, Decimal.to_float(context.monthly_net_after_debt))
  end

  defp enough_safety_net?(context) do
    Decimal.compare(context.current_savings, safety_net(context)) != :lt
  end

  defp positive_surplus?(context) do
    Decimal.compare(context.monthly_net_after_debt, Decimal.new(0)) != :lt
  end

  defp months_between(from, to) do
    (to.year - from.year) * 12 + (to.month - from.month)
  end

  # Compound interest formula with regular monthly contributions.
  defp future_value(initial, monthly, annual_rate, years) do
    r = annual_rate / 12
    n = years * 12

    if abs(r) < 1.0e-10 do
      initial + monthly * n
    else
      growth = :math.pow(1 + r, n)
      initial * growth + monthly * (growth - 1) / r
    end
  end

  # Reverse of future_value: monthly contribution needed to reach a target.
  defp required_monthly(target, initial, annual_rate, years) do
    r = annual_rate / 12
    n = years * 12

    if abs(r) < 1.0e-10 do
      (target - initial) / max(1, n)
    else
      growth = :math.pow(1 + r, n)
      (target - initial * growth) * r / (growth - 1)
    end
  end

  defp parse_amount(val) when is_binary(val) do
    case Float.parse(val) do
      {f, _} when f > 0 -> {:ok, f}
      _ -> :error
    end
  end

  defp parse_amount(_), do: :error

  defp fmt(value) when is_float(value) do
    rounded = Float.round(value, 2)
    sign = if rounded < 0, do: "-", else: ""
    str = :erlang.float_to_binary(abs(rounded), decimals: 2)
    [int_str, dec_str] = String.split(str, ".")

    formatted_int =
      int_str
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.chunk_every(3)
      |> Enum.map_join(" ", &Enum.join/1)
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.join()

    "#{sign}#{formatted_int}.#{dec_str}"
  end

  defp fmt_d(value), do: fmt(Decimal.to_float(value))
end
