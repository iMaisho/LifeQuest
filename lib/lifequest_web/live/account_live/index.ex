defmodule LifequestWeb.AccountLive.Index do
  use LifequestWeb, :live_view

  alias Lifequest.Finances

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Accounts
        <:actions>
          <.button variant="primary" navigate={~p"/accounts/new"}>
            <.icon name="hero-plus" /> New Account
          </.button>
        </:actions>
      </.header>

      <.table
        id="accounts"
        rows={@streams.accounts}
        row_click={fn {_id, account} -> JS.navigate(~p"/accounts/#{account}") end}
      >
        <:col :let={{_id, account}} label="Label">{account.label}</:col>
        <:col :let={{_id, account}} label="Type">{account.type}</:col>
        <:col :let={{_id, account}} label="Balance">{account.balance}</:col>
        <:col :let={{_id, account}} label="Interest rate">{account.interest_rate}</:col>
        <:col :let={{_id, account}} label="Is active">{account.is_active}</:col>
        <:action :let={{_id, account}}>
          <div class="sr-only">
            <.link navigate={~p"/accounts/#{account}"}>Show</.link>
          </div>
          <.link navigate={~p"/accounts/#{account}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, account}}>
          <.link
            phx-click={JS.push("delete", value: %{id: account.id}) |> hide("##{id}")}
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
      Finances.subscribe_accounts(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Accounts")
     |> stream(:accounts, list_accounts(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    account = Finances.get_account!(socket.assigns.current_scope, id)
    {:ok, _} = Finances.delete_account(socket.assigns.current_scope, account)

    {:noreply, stream_delete(socket, :accounts, account)}
  end

  @impl true
  def handle_info({type, %Lifequest.Finances.Account{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :accounts, list_accounts(socket.assigns.current_scope), reset: true)}
  end

  defp list_accounts(current_scope) do
    Finances.list_accounts(current_scope)
  end
end
