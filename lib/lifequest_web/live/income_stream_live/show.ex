defmodule LifequestWeb.IncomeStreamLive.Show do
  use LifequestWeb, :live_view

  alias Lifequest.Finances

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Income stream {@income_stream.id}
        <:subtitle>This is a income_stream record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/income_streams"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/income_streams/#{@income_stream}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit income_stream
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Label">{@income_stream.label}</:item>
        <:item title="Type">{@income_stream.type}</:item>
        <:item title="Amount">{@income_stream.amount}</:item>
        <:item title="Frequency">{@income_stream.frequency}</:item>
        <:item title="Start date">{@income_stream.start_date}</:item>
        <:item title="End date">{@income_stream.end_date}</:item>
        <:item title="Is active">{@income_stream.is_active}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Finances.subscribe_income_streams(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Income stream")
     |> assign(:income_stream, Finances.get_income_stream!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Lifequest.Finances.IncomeStream{id: id} = income_stream},
        %{assigns: %{income_stream: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :income_stream, income_stream)}
  end

  def handle_info(
        {:deleted, %Lifequest.Finances.IncomeStream{id: id}},
        %{assigns: %{income_stream: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current income_stream was deleted.")
     |> push_navigate(to: ~p"/income_streams")}
  end

  def handle_info({type, %Lifequest.Finances.IncomeStream{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
