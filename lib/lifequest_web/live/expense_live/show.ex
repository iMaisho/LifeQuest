defmodule LifequestWeb.ExpenseLive.Show do
  use LifequestWeb, :live_view

  alias Lifequest.Finances

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Expense {@expense.id}
        <:subtitle>This is a expense record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/expenses"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/expenses/#{@expense}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit expense
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@expense.name}</:item>
        <:item title="Type">{@expense.type}</:item>
        <:item title="Amount">{@expense.amount}</:item>
        <:item title="Frequency">{@expense.frequency}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Finances.subscribe_expenses(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Expense")
     |> assign(:expense, Finances.get_expense!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Lifequest.Finances.Expense{id: id} = expense},
        %{assigns: %{expense: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :expense, expense)}
  end

  def handle_info(
        {:deleted, %Lifequest.Finances.Expense{id: id}},
        %{assigns: %{expense: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current expense was deleted.")
     |> push_navigate(to: ~p"/expenses")}
  end

  def handle_info({type, %Lifequest.Finances.Expense{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
