defmodule LifequestWeb.IncomeStreamLive.Form do
  use LifequestWeb, :live_view

  alias Lifequest.Finances
  alias Lifequest.Finances.IncomeStream

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage income_stream records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="income_stream-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:label]} type="text" label="Label" />
        <.input
          field={@form[:type]}
          type="select"
          label="Type"
          prompt="Choose a value"
          options={Ecto.Enum.values(Lifequest.Finances.IncomeStream, :type)}
        />
        <.input field={@form[:amount]} type="number" label="Amount" step="any" />
        <.input
          field={@form[:frequency]}
          type="select"
          label="Frequency"
          prompt="Choose a value"
          options={Ecto.Enum.values(Lifequest.Finances.IncomeStream, :frequency)}
        />
        <.input field={@form[:start_date]} type="date" label="Start date" />
        <.input field={@form[:end_date]} type="date" label="End date" />
        <.input field={@form[:is_active]} type="checkbox" label="Is active" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Income stream</.button>
          <.button navigate={return_path(@current_scope, @return_to, @income_stream)}>Cancel</.button>
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
    income_stream = Finances.get_income_stream!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Income stream")
    |> assign(:income_stream, income_stream)
    |> assign(:form, to_form(Finances.change_income_stream(socket.assigns.current_scope, income_stream)))
  end

  defp apply_action(socket, :new, _params) do
    income_stream = %IncomeStream{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Income stream")
    |> assign(:income_stream, income_stream)
    |> assign(:form, to_form(Finances.change_income_stream(socket.assigns.current_scope, income_stream)))
  end

  @impl true
  def handle_event("validate", %{"income_stream" => income_stream_params}, socket) do
    changeset = Finances.change_income_stream(socket.assigns.current_scope, socket.assigns.income_stream, income_stream_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"income_stream" => income_stream_params}, socket) do
    save_income_stream(socket, socket.assigns.live_action, income_stream_params)
  end

  defp save_income_stream(socket, :edit, income_stream_params) do
    case Finances.update_income_stream(socket.assigns.current_scope, socket.assigns.income_stream, income_stream_params) do
      {:ok, income_stream} ->
        {:noreply,
         socket
         |> put_flash(:info, "Income stream updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, income_stream)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_income_stream(socket, :new, income_stream_params) do
    case Finances.create_income_stream(socket.assigns.current_scope, income_stream_params) do
      {:ok, income_stream} ->
        {:noreply,
         socket
         |> put_flash(:info, "Income stream created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, income_stream)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _income_stream), do: ~p"/income_streams"
  defp return_path(_scope, "show", income_stream), do: ~p"/income_streams/#{income_stream}"
end
