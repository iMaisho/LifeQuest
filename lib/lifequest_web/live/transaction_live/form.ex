defmodule LifequestWeb.TransactionLive.Form do
  use LifequestWeb, :live_view

  alias Lifequest.Finances
  alias Lifequest.Finances.Transaction

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage transaction records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="transaction-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:label]} type="text" label="Label" />
        <.input
          field={@form[:direction]}
          type="select"
          label="Direction"
          prompt="Choose a value"
          options={Ecto.Enum.values(Lifequest.Finances.Transaction, :direction)}
        />
        <.input
          field={@form[:income_type]}
          type="select"
          label="Income type"
          prompt="Choose a value"
          options={Ecto.Enum.values(Lifequest.Finances.Transaction, :income_type)}
        />
        <.input
          field={@form[:expense_type]}
          type="select"
          label="Expense type"
          prompt="Choose a value"
          options={Ecto.Enum.values(Lifequest.Finances.Transaction, :expense_type)}
        />
        <.input field={@form[:amount]} type="number" label="Amount" step="any" />
        <.input field={@form[:date]} type="date" label="Date" />
        <.input field={@form[:is_recurring]} type="checkbox" label="Is recurring" />
        <.input field={@form[:is_active]} type="checkbox" label="Is active" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Transaction</.button>
          <.button navigate={return_path(@current_scope, @return_to, @transaction)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    transaction = Finances.get_transaction!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Transaction")
    |> assign(:transaction, transaction)
    |> assign(
      :form,
      to_form(Finances.change_transaction(socket.assigns.current_scope, transaction))
    )
  end

  defp apply_action(socket, :new, _params) do
    transaction = %Transaction{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Transaction")
    |> assign(:transaction, transaction)
    |> assign(
      :form,
      to_form(Finances.change_transaction(socket.assigns.current_scope, transaction))
    )
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset =
      Finances.change_transaction(
        socket.assigns.current_scope,
        socket.assigns.transaction,
        transaction_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    save_transaction(socket, socket.assigns.live_action, transaction_params)
  end

  defp save_transaction(socket, :edit, transaction_params) do
    case Finances.update_transaction(
           socket.assigns.current_scope,
           socket.assigns.transaction,
           transaction_params
         ) do
      {:ok, transaction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transaction updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, transaction)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_transaction(socket, :new, transaction_params) do
    case Finances.create_transaction(socket.assigns.current_scope, transaction_params) do
      {:ok, transaction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transaction created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, transaction)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _transaction), do: ~p"/transactions"
  defp return_path(_scope, "show", transaction), do: ~p"/transactions/#{transaction}"
end
