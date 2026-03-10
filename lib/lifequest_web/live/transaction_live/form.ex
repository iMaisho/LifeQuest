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
        <:subtitle>{@subtitle}</:subtitle>
      </.header>

      <.form for={@form} id="transaction-form" phx-change="validate" phx-submit="save">
        <input type="hidden" name="transaction[direction]" value={@direction} />
        <input type="hidden" name="transaction[income_type]" value={@income_type} :if={@direction == :income} />
        <input type="hidden" name="transaction[expense_type]" value={@expense_type} :if={@direction == :expense} />

        <.input field={@form[:label]} type="text" label={gettext("Label")} />
        <.input field={@form[:amount]} type="number" label={gettext("Amount")} step="any" />
        <.input field={@form[:date]} type="date" label={gettext("Date")} />
        <.input field={@form[:is_recurring]} type="checkbox" label={gettext("Recurring")} />

        <.input
          field={@form[:account_id]}
          type="select"
          label={gettext("Account")}
          prompt={gettext("Choose an account")}
          options={@account_options}
        />

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">
            {gettext("Save")}
          </.button>
          <.button navigate={~p"/finances"}>
            {gettext("Cancel")}
          </.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  # --- Mount ---

  @impl true
  def mount(params, _session, socket) do
    scope = socket.assigns.current_scope
    accounts = Finances.list_accounts(scope)

    account_options =
      Enum.map(accounts, fn a -> {a.label, a.id} end)

    direction = parse_direction(params["direction"])
    income_type = parse_income_type(params["income_type"])
    expense_type = parse_expense_type(params["expense_type"])

    {:ok,
      socket
      |> assign(:direction, direction)
      |> assign(:income_type, income_type)
      |> assign(:expense_type, expense_type)
      |> assign(:account_options, account_options)
      |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    transaction = Finances.get_transaction!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, page_title(transaction.direction, :edit))
    |> assign(:subtitle, page_subtitle(transaction.direction))
    |> assign(:direction, transaction.direction)
    |> assign(:income_type, transaction.income_type)
    |> assign(:expense_type, transaction.expense_type)
    |> assign(:transaction, transaction)
    |> assign(:form, to_form(Finances.change_transaction(socket.assigns.current_scope, transaction)))
  end

  defp apply_action(socket, :new, _params) do
    direction = socket.assigns.direction
    income_type = socket.assigns.income_type
    expense_type = socket.assigns.expense_type

    transaction = %Transaction{
      direction: direction,
      income_type: income_type,
      expense_type: expense_type,
      date: Date.utc_today()
    }

    socket
    |> assign(:page_title, page_title(direction, :new))
    |> assign(:subtitle, page_subtitle(direction))
    |> assign(:transaction, transaction)
    |> assign(:form, to_form(Finances.change_transaction(socket.assigns.current_scope, transaction)))
  end

  # --- Events ---

  @impl true
  def handle_event("validate", %{"transaction" => params}, socket) do
    changeset =
      Finances.change_transaction(
        socket.assigns.current_scope,
        socket.assigns.transaction,
        params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"transaction" => params}, socket) do
    save_transaction(socket, socket.assigns.live_action, params)
  end

  defp save_transaction(socket, :edit, params) do
    case Finances.update_transaction(
           socket.assigns.current_scope,
           socket.assigns.transaction,
           params
         ) do
      {:ok, _transaction} ->
        {:noreply,
          socket
          |> put_flash(:info, gettext("Transaction updated successfully"))
          |> push_navigate(to: ~p"/finances")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_transaction(socket, :new, params) do
    case Finances.create_transaction(socket.assigns.current_scope, params) do
      {:ok, _transaction} ->
        {:noreply,
          socket
          |> put_flash(:info, gettext("Transaction created successfully"))
          |> push_navigate(to: ~p"/finances")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # --- Helpers ---

  defp parse_direction("income"), do: :income
  defp parse_direction("expense"), do: :expense
  defp parse_direction(_), do: :income

  defp parse_income_type(nil), do: nil
  defp parse_income_type(type) do
    String.to_existing_atom(type)
  rescue
    ArgumentError -> nil
  end

  defp parse_expense_type(nil), do: nil
  defp parse_expense_type(type) do
    String.to_existing_atom(type)
  rescue
    ArgumentError -> nil
  end

  defp page_title(:income, :new), do: gettext("New income")
  defp page_title(:expense, :new), do: gettext("New expense")
  defp page_title(:income, :edit), do: gettext("Edit income")
  defp page_title(:expense, :edit), do: gettext("Edit expense")
  defp page_title(_, action), do: if(action == :new, do: gettext("New transaction"), else: gettext("Edit transaction"))

  defp page_subtitle(:income), do: gettext("Add an income source to your financial profile.")
  defp page_subtitle(:expense), do: gettext("Add an expense to your financial profile.")
  defp page_subtitle(_), do: gettext("Manage your transaction.")
end