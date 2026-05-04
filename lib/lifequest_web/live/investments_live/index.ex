defmodule LifequestWeb.InvestmentsLive.Index do
  use LifequestWeb, :live_view

  @durations [1, 5, 10, 20, 30]

  @safe_placement %{rate: 0.03}

  @risky_placement %{
    rate_pessimistic: -0.15,
    rate_expected: 0.08,
    rate_optimistic: 0.20
  }

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <h1 class="text-4xl font-bold mb-2">{gettext("Investments")}</h1>
      <p class="text-sm opacity-70 mb-8">
        {gettext("Simulate the growth of your investments over time.")}
      </p>

      <div class="card bg-base-200 shadow mb-8">
        <div class="card-body">
          <h2 class="font-semibold mb-3">{gettext("Simulation horizon")}</h2>
          <div class="flex flex-wrap gap-2 mb-3">
            <%= for d <- @durations do %>
              <button
                phx-click="set_duration"
                phx-value-years={d}
                class={["btn btn-sm", @duration == d && "btn-primary", @duration != d && "btn-outline"]}
              >
                {gettext("%{years} years", years: d)}
              </button>
            <% end %>
          </div>
          <form phx-change="set_custom_duration" class="flex items-center gap-2">
            <input
              type="number"
              name="custom_years"
              value={@custom_duration}
              placeholder={gettext("Custom")}
              phx-debounce="500"
              class="input input-sm input-bordered w-36"
              min="1"
              max="50"
            />
            <span class="text-sm opacity-60">{gettext("years")}</span>
          </form>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <%!-- Safe placement --%>
        <div class="card bg-base-200 shadow">
          <div class="card-body">
            <div class="flex items-start justify-between mb-1">
              <h2 class="card-title text-base">{gettext("Safe Savings Account")}</h2>
              <span class="badge badge-success badge-sm">{gettext("Guaranteed")}</span>
            </div>
            <p class="text-xs opacity-60 mb-1">
              {gettext("Secured savings, guaranteed capital")}
            </p>
            <p class="text-success font-semibold text-sm mb-4">
              {fmt_rate(@safe_placement.rate)}% / {gettext("year")}
            </p>

            <.form for={@safe_form} phx-change="update_safe" class="space-y-3">
              <.input
                field={@safe_form[:initial]}
                type="number"
                label={gettext("Initial investment (€)")}
                min="0"
                step="100"
                phx-debounce="300"
              />
              <.input
                field={@safe_form[:monthly]}
                type="number"
                label={gettext("Monthly transfer (€)")}
                min="0"
                step="50"
                phx-debounce="300"
              />
            </.form>

            <div class="divider my-4" />

            <div class="space-y-2">
              <div class="flex justify-between text-sm">
                <span class="opacity-60">{gettext("Invested capital")}</span>
                <span>{fmt(@result_safe.capital)} €</span>
              </div>
              <div class="flex justify-between text-sm">
                <span class="opacity-60">{gettext("Generated interest")}</span>
                <span class="text-success">{fmt(@result_safe.gains)} €</span>
              </div>
              <div class="flex justify-between font-bold border-t border-base-300 pt-2 mt-1">
                <span>{gettext("Value in %{years} years", years: @duration)}</span>
                <span class="text-success">{fmt(@result_safe.final)} €</span>
              </div>
            </div>
          </div>
        </div>

        <%!-- Risky placement --%>
        <div class="card bg-base-200 shadow">
          <div class="card-body">
            <div class="flex items-start justify-between mb-1">
              <h2 class="card-title text-base">{gettext("Dynamic Portfolio")}</h2>
              <span class="badge badge-warning badge-sm">{gettext("Variable")}</span>
            </div>
            <p class="text-xs opacity-60 mb-1">
              {gettext("Variable-rate equity market investment")}
            </p>
            <div class="flex gap-2 mb-4 text-xs font-medium">
              <span class="text-error">{fmt_rate(@risky_placement.rate_pessimistic)}%</span>
              <span class="opacity-30">/</span>
              <span class="text-primary">{fmt_rate(@risky_placement.rate_expected)}%</span>
              <span class="opacity-30">/</span>
              <span class="text-success">{fmt_rate(@risky_placement.rate_optimistic)}%</span>
              <span class="opacity-40">{gettext("per year")}</span>
            </div>

            <.form for={@risky_form} phx-change="update_risky" class="space-y-3">
              <.input
                field={@risky_form[:initial]}
                type="number"
                label={gettext("Initial investment (€)")}
                min="0"
                step="100"
                phx-debounce="300"
              />
              <.input
                field={@risky_form[:monthly]}
                type="number"
                label={gettext("Monthly transfer (€)")}
                min="0"
                step="50"
                phx-debounce="300"
              />
            </.form>

            <div class="divider my-4" />

            <p class="text-xs opacity-50 mb-3">
              {gettext("Invested capital: %{amount} €", amount: fmt(@result_risky.capital))}
            </p>
            <div class="grid grid-cols-3 gap-2">
              <div class="rounded-lg bg-error/10 p-3 text-center">
                <p class="text-xs opacity-60 mb-1">{gettext("Pessimistic")}</p>
                <p class={[
                  "font-bold text-sm",
                  @result_risky.pessimistic < 0 && "text-error",
                  @result_risky.pessimistic >= 0 && "text-base-content"
                ]}>
                  {fmt(@result_risky.pessimistic)} €
                </p>
              </div>
              <div class="rounded-lg bg-primary/10 p-3 text-center">
                <p class="text-xs opacity-60 mb-1">{gettext("Expected")}</p>
                <p class="font-bold text-sm text-primary">{fmt(@result_risky.expected)} €</p>
              </div>
              <div class="rounded-lg bg-success/10 p-3 text-center">
                <p class="text-xs opacity-60 mb-1">{gettext("Optimistic")}</p>
                <p class="font-bold text-sm text-success">{fmt(@result_risky.optimistic)} €</p>
              </div>
            </div>
            <p class="text-xs opacity-40 text-right mt-2">
              {gettext("in %{years} years", years: @duration)}
            </p>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, gettext("Investments"))
     |> assign(:durations, @durations)
     |> assign(:duration, 10)
     |> assign(:custom_duration, "")
     |> assign(:safe_placement, @safe_placement)
     |> assign(:risky_placement, @risky_placement)
     |> assign(:safe_initial, 0.0)
     |> assign(:safe_monthly, 0.0)
     |> assign(:risky_initial, 0.0)
     |> assign(:risky_monthly, 0.0)
     |> assign(:safe_form, to_form(%{"initial" => "0", "monthly" => "0"}, as: :safe))
     |> assign(:risky_form, to_form(%{"initial" => "0", "monthly" => "0"}, as: :risky))
     |> compute_results()}
  end

  @impl true
  def handle_event("set_duration", %{"years" => years_str}, socket) do
    years = String.to_integer(years_str)

    {:noreply,
     socket
     |> assign(:duration, years)
     |> assign(:custom_duration, "")
     |> compute_results()}
  end

  @impl true
  def handle_event("set_custom_duration", %{"custom_years" => val}, socket) do
    case Integer.parse(val) do
      {years, ""} when years >= 1 and years <= 50 ->
        {:noreply,
         socket
         |> assign(:duration, years)
         |> assign(:custom_duration, val)
         |> compute_results()}

      _ ->
        {:noreply, assign(socket, :custom_duration, val)}
    end
  end

  @impl true
  def handle_event("update_safe", %{"safe" => params}, socket) do
    initial = parse_float(Map.get(params, "initial", "0"))
    monthly = parse_float(Map.get(params, "monthly", "0"))

    {:noreply,
     socket
     |> assign(:safe_initial, initial)
     |> assign(:safe_monthly, monthly)
     |> assign(:safe_form, to_form(params, as: :safe))
     |> compute_results()}
  end

  @impl true
  def handle_event("update_risky", %{"risky" => params}, socket) do
    initial = parse_float(Map.get(params, "initial", "0"))
    monthly = parse_float(Map.get(params, "monthly", "0"))

    {:noreply,
     socket
     |> assign(:risky_initial, initial)
     |> assign(:risky_monthly, monthly)
     |> assign(:risky_form, to_form(params, as: :risky))
     |> compute_results()}
  end

  defp compute_results(socket) do
    %{
      duration: years,
      safe_initial: safe_initial,
      safe_monthly: safe_monthly,
      risky_initial: risky_initial,
      risky_monthly: risky_monthly
    } = socket.assigns

    safe_capital = safe_initial + safe_monthly * years * 12
    safe_final = future_value(safe_initial, safe_monthly, @safe_placement.rate, years)

    result_safe = %{
      final: safe_final,
      capital: safe_capital,
      gains: safe_final - safe_capital
    }

    risky_capital = risky_initial + risky_monthly * years * 12

    result_risky = %{
      pessimistic: future_value(risky_initial, risky_monthly, @risky_placement.rate_pessimistic, years),
      expected: future_value(risky_initial, risky_monthly, @risky_placement.rate_expected, years),
      optimistic: future_value(risky_initial, risky_monthly, @risky_placement.rate_optimistic, years),
      capital: risky_capital
    }

    socket
    |> assign(:result_safe, result_safe)
    |> assign(:result_risky, result_risky)
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

  defp parse_float(val) when is_binary(val) do
    case Float.parse(val) do
      {f, _} -> f
      :error -> 0.0
    end
  end

  defp parse_float(f) when is_float(f), do: f
  defp parse_float(i) when is_integer(i), do: i * 1.0
  defp parse_float(_), do: 0.0

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
      |> Enum.map(&Enum.join/1)
      |> Enum.join(" ")
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.join()

    "#{sign}#{formatted_int}.#{dec_str}"
  end

  defp fmt_rate(rate) do
    pct = rate * 100
    rounded = Float.round(pct, 1)
    prefix = if rounded >= 0, do: "+", else: ""

    if rounded == Float.round(pct, 0) do
      "#{prefix}#{trunc(rounded)}"
    else
      "#{prefix}#{rounded}"
    end
  end
end
