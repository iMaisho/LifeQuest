defmodule LifequestWeb.FinancialProfileLive.Form do
  use LifequestWeb, :live_view

  alias Lifequest.Finances
  alias Lifequest.Finances.FinancialProfile

  @fields ~w(current_savings current_debts monthly_debt_payment net_worth employment_status)a

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>{@subtitle}</:subtitle>
      </.header>

      <.form for={@form} id="financial_profile-form" phx-change="validate" phx-submit="save">
        <%= if @focused_field do %>
          <.profile_input form={@form} field={@focused_field} />
        <% else %>
          <.profile_input :for={field <- @fields} form={@form} field={field} />
        <% end %>
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

  # --- Field Components ---

  defp profile_input(%{field: :employment_status} = assigns) do
    ~H"""
    <.input
      field={@form[:employment_status]}
      type="select"
      label={gettext("Employment status")}
      prompt={gettext("Choose a value")}
      options={employment_status_options()}
    />
    """
  end

  defp profile_input(assigns) do
    ~H"""
    <.input
      field={@form[@field]}
      type="number"
      label={field_label(@field)}
      step="any"
    />
    """
  end

  # --- Mount ---

  @impl true
  def mount(params, _session, socket) do
    focused_field = parse_field(params["field"])

    {:ok,
     socket
     |> assign(:focused_field, focused_field)
     |> assign(:fields, @fields)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    financial_profile = Finances.get_financial_profile!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, page_title(socket.assigns.focused_field, :edit))
    |> assign(:subtitle, page_subtitle(socket.assigns.focused_field, :edit))
    |> assign(:financial_profile, financial_profile)
    |> assign(
      :form,
      to_form(Finances.change_financial_profile(socket.assigns.current_scope, financial_profile))
    )
  end

  defp apply_action(socket, :new, _params) do
    financial_profile = %FinancialProfile{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, page_title(socket.assigns.focused_field, :new))
    |> assign(:subtitle, page_subtitle(socket.assigns.focused_field, :new))
    |> assign(:financial_profile, financial_profile)
    |> assign(
      :form,
      to_form(Finances.change_financial_profile(socket.assigns.current_scope, financial_profile))
    )
  end

  # --- Events ---

  @impl true
  def handle_event("validate", %{"financial_profile" => params}, socket) do
    changeset =
      Finances.change_financial_profile(
        socket.assigns.current_scope,
        socket.assigns.financial_profile,
        params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"financial_profile" => params}, socket) do
    save_financial_profile(socket, socket.assigns.live_action, params)
  end

  defp save_financial_profile(socket, :edit, params) do
    case Finances.update_financial_profile(
           socket.assigns.current_scope,
           socket.assigns.financial_profile,
           params
         ) do
      {:ok, _financial_profile} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Financial profile updated successfully"))
         |> push_navigate(to: ~p"/finances")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_financial_profile(socket, :new, params) do
    case Finances.create_financial_profile(socket.assigns.current_scope, params) do
      {:ok, _financial_profile} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Financial profile created successfully"))
         |> push_navigate(to: ~p"/finances")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # --- Helpers ---

  defp parse_field(nil), do: nil

  defp parse_field(field) when is_binary(field) do
    atom = String.to_existing_atom(field)
    if atom in @fields, do: atom, else: nil
  rescue
    ArgumentError -> nil
  end

  defp page_title(nil, :edit), do: gettext("Edit financial profile")
  defp page_title(nil, :new), do: gettext("New financial profile")
  defp page_title(field, :edit), do: gettext("Edit %{field}", field: field_label(field))
  defp page_title(field, :new), do: gettext("Set %{field}", field: field_label(field))

  defp page_subtitle(nil, _action), do: gettext("Manage your financial profile information.")

  defp page_subtitle(_field, _action),
    do: gettext("Update this information to keep your profile accurate.")

  defp field_label(:current_savings), do: gettext("Current savings")
  defp field_label(:current_debts), do: gettext("Current debts")
  defp field_label(:monthly_debt_payment), do: gettext("Monthly debt payment")
  defp field_label(:net_worth), do: gettext("Net worth")
  defp field_label(:employment_status), do: gettext("Employment status")

  defp employment_status_options do
    [
      {gettext("Permanent contract (CDI)"), :cdi},
      {gettext("Fixed-term contract (CDD)"), :cdd},
      {gettext("Freelance"), :freelance},
      {gettext("Business owner"), :business_owner},
      {gettext("Unemployed"), :unemployed},
      {gettext("Retired"), :retired}
    ]
  end
end
