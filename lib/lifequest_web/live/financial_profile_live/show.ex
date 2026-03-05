defmodule LifequestWeb.FinancialProfileLive.Show do
  use LifequestWeb, :live_view

  alias Lifequest.Finances

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Financial profile {@financial_profile.id}
        <:subtitle>This is a financial_profile record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/financial_profiles"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/financial_profiles/#{@financial_profile}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit financial_profile
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Current savings">{@financial_profile.current_savings}</:item>
        <:item title="Current debts">{@financial_profile.current_debts}</:item>
        <:item title="Monthly debt payment">{@financial_profile.monthly_debt_payment}</:item>
        <:item title="Net worth">{@financial_profile.net_worth}</:item>
        <:item title="Employment status">{@financial_profile.employment_status}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Finances.subscribe_financial_profiles(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Financial profile")
     |> assign(:financial_profile, Finances.get_financial_profile!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Lifequest.Finances.FinancialProfile{id: id} = financial_profile},
        %{assigns: %{financial_profile: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :financial_profile, financial_profile)}
  end

  def handle_info(
        {:deleted, %Lifequest.Finances.FinancialProfile{id: id}},
        %{assigns: %{financial_profile: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current financial_profile was deleted.")
     |> push_navigate(to: ~p"/financial_profiles")}
  end

  def handle_info({type, %Lifequest.Finances.FinancialProfile{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
