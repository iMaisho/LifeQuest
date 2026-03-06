defmodule LifequestWeb.IncomeStreamLive.Index do
  use LifequestWeb, :live_view

  alias Lifequest.Finances

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Income streams
        <:actions>
          <.button variant="primary" navigate={~p"/income_streams/new"}>
            <.icon name="hero-plus" /> New Income stream
          </.button>
        </:actions>
      </.header>

      <.table
        id="income_streams"
        rows={@streams.income_streams}
        row_click={fn {_id, income_stream} -> JS.navigate(~p"/income_streams/#{income_stream}") end}
      >
        <:col :let={{_id, income_stream}} label="Label">{income_stream.label}</:col>
        <:col :let={{_id, income_stream}} label="Type">{income_stream.type}</:col>
        <:col :let={{_id, income_stream}} label="Amount">{income_stream.amount}</:col>
        <:col :let={{_id, income_stream}} label="Frequency">{income_stream.frequency}</:col>
        <:col :let={{_id, income_stream}} label="Start date">{income_stream.start_date}</:col>
        <:col :let={{_id, income_stream}} label="End date">{income_stream.end_date}</:col>
        <:col :let={{_id, income_stream}} label="Is active">{income_stream.is_active}</:col>
        <:action :let={{_id, income_stream}}>
          <div class="sr-only">
            <.link navigate={~p"/income_streams/#{income_stream}"}>Show</.link>
          </div>
          <.link navigate={~p"/income_streams/#{income_stream}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, income_stream}}>
          <.link
            phx-click={JS.push("delete", value: %{id: income_stream.id}) |> hide("##{id}")}
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
      Finances.subscribe_income_streams(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Income streams")
     |> stream(:income_streams, list_income_streams(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    income_stream = Finances.get_income_stream!(socket.assigns.current_scope, id)
    {:ok, _} = Finances.delete_income_stream(socket.assigns.current_scope, income_stream)

    {:noreply, stream_delete(socket, :income_streams, income_stream)}
  end

  @impl true
  def handle_info({type, %Lifequest.Finances.IncomeStream{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :income_streams, list_income_streams(socket.assigns.current_scope),
       reset: true
     )}
  end

  defp list_income_streams(current_scope) do
    Finances.list_income_streams(current_scope)
  end
end
