defmodule LifequestWeb.InvestmentsLive.Index do
  use LifequestWeb, :live_view

  @durations [1, 5, 10, 20, 30]

  @placement_sur %{
    name: "Livret Croissance",
    subtitle: "Épargne sécurisée, capital garanti",
    rate: 0.03
  }

  @placement_risque %{
    name: "Portefeuille Actions",
    subtitle: "Investissement en marchés financiers, rendement variable",
    rate_pessimiste: -0.15,
    rate_attendu: 0.08,
    rate_optimiste: 0.20
  }

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <h1 class="text-4xl font-bold mb-2">Investissements</h1>
      <p class="text-sm opacity-70 mb-8">Simulez la croissance de vos placements dans le temps.</p>

      <div class="card bg-base-200 shadow mb-8">
        <div class="card-body">
          <h2 class="font-semibold mb-3">Horizon de simulation</h2>
          <div class="flex flex-wrap gap-2 mb-3">
            <%= for d <- @durations do %>
              <button
                phx-click="set_duration"
                phx-value-years={d}
                class={["btn btn-sm", @duration == d && "btn-primary", @duration != d && "btn-outline"]}
              >
                {d} ans
              </button>
            <% end %>
          </div>
          <form phx-change="set_custom_duration" class="flex items-center gap-2">
            <input
              type="number"
              name="custom_years"
              value={@custom_duration}
              placeholder="Personnalisé"
              phx-debounce="500"
              class="input input-sm input-bordered w-36"
              min="1"
              max="50"
            />
            <span class="text-sm opacity-60">ans</span>
          </form>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <%!-- Placement sûr --%>
        <div class="card bg-base-200 shadow">
          <div class="card-body">
            <div class="flex items-start justify-between mb-1">
              <h2 class="card-title text-base">{@placement_sur.name}</h2>
              <span class="badge badge-success badge-sm">Garanti</span>
            </div>
            <p class="text-xs opacity-60 mb-1">{@placement_sur.subtitle}</p>
            <p class="text-success font-semibold text-sm mb-4">
              {fmt_rate(@placement_sur.rate)}% / an
            </p>

            <.form for={@sur_form} phx-change="update_sur" class="space-y-3">
              <.input
                field={@sur_form[:initial]}
                type="number"
                label="Investissement initial (€)"
                min="0"
                step="100"
                phx-debounce="300"
              />
              <.input
                field={@sur_form[:monthly]}
                type="number"
                label="Virement mensuel (€)"
                min="0"
                step="50"
                phx-debounce="300"
              />
            </.form>

            <div class="divider my-4" />

            <div class="space-y-2">
              <div class="flex justify-between text-sm">
                <span class="opacity-60">Capital investi</span>
                <span>{fmt(@result_sur.capital)} €</span>
              </div>
              <div class="flex justify-between text-sm">
                <span class="opacity-60">Intérêts générés</span>
                <span class="text-success">{fmt(@result_sur.gains)} €</span>
              </div>
              <div class="flex justify-between font-bold border-t border-base-300 pt-2 mt-1">
                <span>Valeur dans {@duration} ans</span>
                <span class="text-success">{fmt(@result_sur.final)} €</span>
              </div>
            </div>
          </div>
        </div>

        <%!-- Placement risqué --%>
        <div class="card bg-base-200 shadow">
          <div class="card-body">
            <div class="flex items-start justify-between mb-1">
              <h2 class="card-title text-base">{@placement_risque.name}</h2>
              <span class="badge badge-warning badge-sm">Variable</span>
            </div>
            <p class="text-xs opacity-60 mb-1">{@placement_risque.subtitle}</p>
            <div class="flex gap-2 mb-4 text-xs font-medium">
              <span class="text-error">{fmt_rate(@placement_risque.rate_pessimiste)}%</span>
              <span class="opacity-30">/</span>
              <span class="text-primary">{fmt_rate(@placement_risque.rate_attendu)}%</span>
              <span class="opacity-30">/</span>
              <span class="text-success">{fmt_rate(@placement_risque.rate_optimiste)}%</span>
              <span class="opacity-40">par an</span>
            </div>

            <.form for={@risque_form} phx-change="update_risque" class="space-y-3">
              <.input
                field={@risque_form[:initial]}
                type="number"
                label="Investissement initial (€)"
                min="0"
                step="100"
                phx-debounce="300"
              />
              <.input
                field={@risque_form[:monthly]}
                type="number"
                label="Virement mensuel (€)"
                min="0"
                step="50"
                phx-debounce="300"
              />
            </.form>

            <div class="divider my-4" />

            <p class="text-xs opacity-50 mb-3">
              Capital investi : {fmt(@result_risque.capital)} €
            </p>
            <div class="grid grid-cols-3 gap-2">
              <div class="rounded-lg bg-error/10 p-3 text-center">
                <p class="text-xs opacity-60 mb-1">Pessimiste</p>
                <p class={[
                  "font-bold text-sm",
                  @result_risque.pessimiste < 0 && "text-error",
                  @result_risque.pessimiste >= 0 && "text-base-content"
                ]}>
                  {fmt(@result_risque.pessimiste)} €
                </p>
              </div>
              <div class="rounded-lg bg-primary/10 p-3 text-center">
                <p class="text-xs opacity-60 mb-1">Attendu</p>
                <p class="font-bold text-sm text-primary">{fmt(@result_risque.attendu)} €</p>
              </div>
              <div class="rounded-lg bg-success/10 p-3 text-center">
                <p class="text-xs opacity-60 mb-1">Optimiste</p>
                <p class="font-bold text-sm text-success">{fmt(@result_risque.optimiste)} €</p>
              </div>
            </div>
            <p class="text-xs opacity-40 text-right mt-2">dans {@duration} ans</p>
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
     |> assign(:page_title, "Investissements")
     |> assign(:durations, @durations)
     |> assign(:duration, 10)
     |> assign(:custom_duration, "")
     |> assign(:placement_sur, @placement_sur)
     |> assign(:placement_risque, @placement_risque)
     |> assign(:sur_initial, 0.0)
     |> assign(:sur_monthly, 0.0)
     |> assign(:risque_initial, 0.0)
     |> assign(:risque_monthly, 0.0)
     |> assign(:sur_form, to_form(%{"initial" => "0", "monthly" => "0"}, as: :sur))
     |> assign(:risque_form, to_form(%{"initial" => "0", "monthly" => "0"}, as: :risque))
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
  def handle_event("update_sur", %{"sur" => params}, socket) do
    initial = parse_float(Map.get(params, "initial", "0"))
    monthly = parse_float(Map.get(params, "monthly", "0"))

    {:noreply,
     socket
     |> assign(:sur_initial, initial)
     |> assign(:sur_monthly, monthly)
     |> assign(:sur_form, to_form(params, as: :sur))
     |> compute_results()}
  end

  @impl true
  def handle_event("update_risque", %{"risque" => params}, socket) do
    initial = parse_float(Map.get(params, "initial", "0"))
    monthly = parse_float(Map.get(params, "monthly", "0"))

    {:noreply,
     socket
     |> assign(:risque_initial, initial)
     |> assign(:risque_monthly, monthly)
     |> assign(:risque_form, to_form(params, as: :risque))
     |> compute_results()}
  end

  defp compute_results(socket) do
    %{
      duration: years,
      sur_initial: si,
      sur_monthly: sm,
      risque_initial: ri,
      risque_monthly: rm
    } = socket.assigns

    capital_sur = si + sm * years * 12
    final_sur = future_value(si, sm, @placement_sur.rate, years)

    result_sur = %{
      final: final_sur,
      capital: capital_sur,
      gains: final_sur - capital_sur
    }

    capital_risque = ri + rm * years * 12

    result_risque = %{
      pessimiste: future_value(ri, rm, @placement_risque.rate_pessimiste, years),
      attendu: future_value(ri, rm, @placement_risque.rate_attendu, years),
      optimiste: future_value(ri, rm, @placement_risque.rate_optimiste, years),
      capital: capital_risque
    }

    socket
    |> assign(:result_sur, result_sur)
    |> assign(:result_risque, result_risque)
  end

  # Formule de capitalisation avec versements mensuels réguliers.
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

    "#{sign}#{formatted_int},#{dec_str}"
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
