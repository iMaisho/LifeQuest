defmodule LifequestWeb.FinancialProfileLiveTest do
  use LifequestWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lifequest.FinancesFixtures

  @create_attrs %{current_savings: "120.5", current_debts: "120.5", monthly_debt_payment: "120.5", net_worth: "120.5", employment_status: :cdi}
  @update_attrs %{current_savings: "456.7", current_debts: "456.7", monthly_debt_payment: "456.7", net_worth: "456.7", employment_status: :cdd}
  @invalid_attrs %{current_savings: nil, current_debts: nil, monthly_debt_payment: nil, net_worth: nil, employment_status: nil}

  setup :register_and_log_in_user

  defp create_financial_profile(%{scope: scope}) do
    financial_profile = financial_profile_fixture(scope)

    %{financial_profile: financial_profile}
  end

  describe "Index" do
    setup [:create_financial_profile]

    test "lists all financial_profiles", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/financial_profiles")

      assert html =~ "Listing Financial profiles"
    end

    test "saves new financial_profile", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/financial_profiles")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Financial profile")
               |> render_click()
               |> follow_redirect(conn, ~p"/financial_profiles/new")

      assert render(form_live) =~ "New Financial profile"

      assert form_live
             |> form("#financial_profile-form", financial_profile: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#financial_profile-form", financial_profile: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/financial_profiles")

      html = render(index_live)
      assert html =~ "Financial profile created successfully"
    end

    test "updates financial_profile in listing", %{conn: conn, financial_profile: financial_profile} do
      {:ok, index_live, _html} = live(conn, ~p"/financial_profiles")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#financial_profiles-#{financial_profile.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/financial_profiles/#{financial_profile}/edit")

      assert render(form_live) =~ "Edit Financial profile"

      assert form_live
             |> form("#financial_profile-form", financial_profile: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#financial_profile-form", financial_profile: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/financial_profiles")

      html = render(index_live)
      assert html =~ "Financial profile updated successfully"
    end

    test "deletes financial_profile in listing", %{conn: conn, financial_profile: financial_profile} do
      {:ok, index_live, _html} = live(conn, ~p"/financial_profiles")

      assert index_live |> element("#financial_profiles-#{financial_profile.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#financial_profiles-#{financial_profile.id}")
    end
  end

  describe "Show" do
    setup [:create_financial_profile]

    test "displays financial_profile", %{conn: conn, financial_profile: financial_profile} do
      {:ok, _show_live, html} = live(conn, ~p"/financial_profiles/#{financial_profile}")

      assert html =~ "Show Financial profile"
    end

    test "updates financial_profile and returns to show", %{conn: conn, financial_profile: financial_profile} do
      {:ok, show_live, _html} = live(conn, ~p"/financial_profiles/#{financial_profile}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/financial_profiles/#{financial_profile}/edit?return_to=show")

      assert render(form_live) =~ "Edit Financial profile"

      assert form_live
             |> form("#financial_profile-form", financial_profile: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#financial_profile-form", financial_profile: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/financial_profiles/#{financial_profile}")

      html = render(show_live)
      assert html =~ "Financial profile updated successfully"
    end
  end
end
