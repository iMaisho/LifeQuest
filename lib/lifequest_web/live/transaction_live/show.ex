defmodule LifequestWeb.TransactionLive.Show do
  use LifequestWeb, :live_view

  alias Lifequest.Finances

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Transaction {@transaction.id}
        <:subtitle>This is a transaction record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/transactions"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/transactions/#{@transaction}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit transaction
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Label">{@transaction.label}</:item>
        <:item title="Direction">{@transaction.direction}</:item>
        <:item title="Income type">{@transaction.income_type}</:item>
        <:item title="Expense type">{@transaction.expense_type}</:item>
        <:item title="Amount">{@transaction.amount}</:item>
        <:item title="Date">{@transaction.date}</:item>
        <:item title="Is recurring">{@transaction.is_recurring}</:item>
        <:item title="Is active">{@transaction.is_active}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Finances.subscribe_transactions(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Transaction")
     |> assign(:transaction, Finances.get_transaction!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Lifequest.Finances.Transaction{id: id} = transaction},
        %{assigns: %{transaction: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :transaction, transaction)}
  end

  def handle_info(
        {:deleted, %Lifequest.Finances.Transaction{id: id}},
        %{assigns: %{transaction: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current transaction was deleted.")
     |> push_navigate(to: ~p"/transactions")}
  end

  def handle_info({type, %Lifequest.Finances.Transaction{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
