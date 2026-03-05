defmodule LifequestWeb.FinancialProfileLive.Index do
  use LifequestWeb, :live_view

  alias Lifequest.Finances

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Financial profiles
        <:actions>
          <.button variant="primary" navigate={~p"/financial_profiles/new"}>
            <.icon name="hero-plus" /> New Financial profile
          </.button>
        </:actions>
      </.header>

      <.table
        id="financial_profiles"
        rows={@streams.financial_profiles}
        row_click={fn {_id, financial_profile} -> JS.navigate(~p"/financial_profiles/#{financial_profile}") end}
      >
        <:col :let={{_id, financial_profile}} label="Current savings">{financial_profile.current_savings}</:col>
        <:col :let={{_id, financial_profile}} label="Current debts">{financial_profile.current_debts}</:col>
        <:col :let={{_id, financial_profile}} label="Monthly debt payment">{financial_profile.monthly_debt_payment}</:col>
        <:col :let={{_id, financial_profile}} label="Net worth">{financial_profile.net_worth}</:col>
        <:col :let={{_id, financial_profile}} label="Employment status">{financial_profile.employment_status}</:col>
        <:action :let={{_id, financial_profile}}>
          <div class="sr-only">
            <.link navigate={~p"/financial_profiles/#{financial_profile}"}>Show</.link>
          </div>
          <.link navigate={~p"/financial_profiles/#{financial_profile}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, financial_profile}}>
          <.link
            phx-click={JS.push("delete", value: %{id: financial_profile.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Finances.subscribe_financial_profiles(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Financial profiles")
     |> stream(:financial_profiles, list_financial_profiles(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    financial_profile = Finances.get_financial_profile!(socket.assigns.current_scope, id)
    {:ok, _} = Finances.delete_financial_profile(socket.assigns.current_scope, financial_profile)

    {:noreply, stream_delete(socket, :financial_profiles, financial_profile)}
  end

  @impl true
  def handle_info({type, %Lifequest.Finances.FinancialProfile{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :financial_profiles, list_financial_profiles(socket.assigns.current_scope), reset: true)}
  end

  defp list_financial_profiles(current_scope) do
    Finances.list_financial_profiles(current_scope)
  end
end
