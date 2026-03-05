defmodule LifequestWeb.FinancialProfileLive.Form do
  use LifequestWeb, :live_view

  alias Lifequest.Finances
  alias Lifequest.Finances.FinancialProfile

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage financial_profile records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="financial_profile-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:current_savings]} type="number" label="Current savings" step="any" />
        <.input field={@form[:current_debts]} type="number" label="Current debts" step="any" />
        <.input field={@form[:monthly_debt_payment]} type="number" label="Monthly debt payment" step="any" />
        <.input field={@form[:net_worth]} type="number" label="Net worth" step="any" />
        <.input
          field={@form[:employment_status]}
          type="select"
          label="Employment status"
          prompt="Choose a value"
          options={Ecto.Enum.values(Lifequest.Finances.FinancialProfile, :employment_status)}
        />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Financial profile</.button>
          <.button navigate={return_path(@current_scope, @return_to, @financial_profile)}>Cancel</.button>
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
    financial_profile = Finances.get_financial_profile!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Financial profile")
    |> assign(:financial_profile, financial_profile)
    |> assign(:form, to_form(Finances.change_financial_profile(socket.assigns.current_scope, financial_profile)))
  end

  defp apply_action(socket, :new, _params) do
    financial_profile = %FinancialProfile{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Financial profile")
    |> assign(:financial_profile, financial_profile)
    |> assign(:form, to_form(Finances.change_financial_profile(socket.assigns.current_scope, financial_profile)))
  end

  @impl true
  def handle_event("validate", %{"financial_profile" => financial_profile_params}, socket) do
    changeset = Finances.change_financial_profile(socket.assigns.current_scope, socket.assigns.financial_profile, financial_profile_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"financial_profile" => financial_profile_params}, socket) do
    save_financial_profile(socket, socket.assigns.live_action, financial_profile_params)
  end

  defp save_financial_profile(socket, :edit, financial_profile_params) do
    case Finances.update_financial_profile(socket.assigns.current_scope, socket.assigns.financial_profile, financial_profile_params) do
      {:ok, financial_profile} ->
        {:noreply,
         socket
         |> put_flash(:info, "Financial profile updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, financial_profile)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_financial_profile(socket, :new, financial_profile_params) do
    case Finances.create_financial_profile(socket.assigns.current_scope, financial_profile_params) do
      {:ok, financial_profile} ->
        {:noreply,
         socket
         |> put_flash(:info, "Financial profile created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, financial_profile)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _financial_profile), do: ~p"/financial_profiles"
  defp return_path(_scope, "show", financial_profile), do: ~p"/financial_profiles/#{financial_profile}"
end
