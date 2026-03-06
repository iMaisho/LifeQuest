defmodule LifequestWeb.ExpenseLive.Form do
  use LifequestWeb, :live_view

  alias Lifequest.Finances
  alias Lifequest.Finances.Expense

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage expense records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="expense-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input
          field={@form[:type]}
          type="select"
          label="Type"
          prompt="Choose a value"
          options={Ecto.Enum.values(Lifequest.Finances.Expense, :type)}
        />
        <.input field={@form[:amount]} type="number" label="Amount" step="any" />
        <.input
          field={@form[:frequency]}
          type="select"
          label="Frequency"
          prompt="Choose a value"
          options={Ecto.Enum.values(Lifequest.Finances.Expense, :frequency)}
        />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Expense</.button>
          <.button navigate={return_path(@current_scope, @return_to, @expense)}>Cancel</.button>
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
    expense = Finances.get_expense!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Expense")
    |> assign(:expense, expense)
    |> assign(:form, to_form(Finances.change_expense(socket.assigns.current_scope, expense)))
  end

  defp apply_action(socket, :new, _params) do
    expense = %Expense{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Expense")
    |> assign(:expense, expense)
    |> assign(:form, to_form(Finances.change_expense(socket.assigns.current_scope, expense)))
  end

  @impl true
  def handle_event("validate", %{"expense" => expense_params}, socket) do
    changeset =
      Finances.change_expense(
        socket.assigns.current_scope,
        socket.assigns.expense,
        expense_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"expense" => expense_params}, socket) do
    save_expense(socket, socket.assigns.live_action, expense_params)
  end

  defp save_expense(socket, :edit, expense_params) do
    case Finances.update_expense(
           socket.assigns.current_scope,
           socket.assigns.expense,
           expense_params
         ) do
      {:ok, expense} ->
        {:noreply,
         socket
         |> put_flash(:info, "Expense updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, expense)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_expense(socket, :new, expense_params) do
    case Finances.create_expense(socket.assigns.current_scope, expense_params) do
      {:ok, expense} ->
        {:noreply,
         socket
         |> put_flash(:info, "Expense created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, expense)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _expense), do: ~p"/expenses"
  defp return_path(_scope, "show", expense), do: ~p"/expenses/#{expense}"
end
