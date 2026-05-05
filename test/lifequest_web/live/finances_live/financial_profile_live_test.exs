defmodule LifequestWeb.FinancialProfileLive.FormTest do
  use LifequestWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lifequest.FinancesFixtures

  setup :register_and_log_in_user

  describe "New financial profile" do
    test "renders full form", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/financial_profiles/new")

      assert html =~ "Nouveau profil financier"
      assert html =~ "Épargne actuelle"
      assert html =~ "Dettes actuelles"
      assert html =~ "Mensualité de dette"
      assert html =~ "Patrimoine net"
      assert html =~ "Statut professionnel"
    end

    test "creates profile and redirects to finances", %{conn: conn} do
      {:ok, live_view, _html} = live(conn, ~p"/financial_profiles/new")

      assert {:ok, _live, html} =
               live_view
               |> form("#financial_profile-form",
                 financial_profile: %{
                   current_savings: "5000",
                   current_debts: "1000",
                   monthly_debt_payment: "200",
                   net_worth: "50000",
                   employment_status: :cdi
                 }
               )
               |> render_submit()
               |> follow_redirect(conn, ~p"/finances")

      assert html =~ "Profil financier créé avec succès"
    end

    test "shows validation errors", %{conn: conn} do
      {:ok, live_view, _html} = live(conn, ~p"/financial_profiles/new")

      html =
        live_view
        |> form("#financial_profile-form",
          financial_profile: %{
            current_savings: nil,
            current_debts: nil,
            monthly_debt_payment: nil,
            net_worth: nil,
            employment_status: nil
          }
        )
        |> render_change()

      assert html =~ "ne peut pas être vide"
    end
  end

  describe "Edit financial profile - full form" do
    test "renders all fields", %{conn: conn, scope: scope} do
      profile = financial_profile_fixture(scope)

      {:ok, _live, html} = live(conn, ~p"/financial_profiles/#{profile}/edit")

      assert html =~ "Modifier le profil financier"
      assert html =~ "Épargne actuelle"
      assert html =~ "Dettes actuelles"
    end

    test "updates profile and redirects to finances", %{conn: conn, scope: scope} do
      profile = financial_profile_fixture(scope)

      {:ok, live_view, _html} = live(conn, ~p"/financial_profiles/#{profile}/edit")

      assert {:ok, _live, html} =
               live_view
               |> form("#financial_profile-form",
                 financial_profile: %{
                   current_savings: "9999"
                 }
               )
               |> render_submit()
               |> follow_redirect(conn, ~p"/finances")

      assert html =~ "Profil financier mis à jour avec succès"
    end
  end

  describe "Edit financial profile - single field" do
    test "renders only the focused field for current_savings", %{conn: conn, scope: scope} do
      profile = financial_profile_fixture(scope)

      {:ok, _live, html} =
        live(conn, ~p"/financial_profiles/#{profile}/edit?field=current_savings")

      assert html =~ "Épargne actuelle"
      refute html =~ "Dettes actuelles"
      refute html =~ "Mensualité de dette"
      refute html =~ "Patrimoine net"
      refute html =~ "Statut professionnel"
    end

    test "renders only the focused field for employment_status", %{conn: conn, scope: scope} do
      profile = financial_profile_fixture(scope)

      {:ok, _live, html} =
        live(conn, ~p"/financial_profiles/#{profile}/edit?field=employment_status")

      assert html =~ "Statut professionnel"
      refute html =~ "Épargne actuelle"
      refute html =~ "Dettes actuelles"
    end

    test "updates single field and redirects", %{conn: conn, scope: scope} do
      profile = financial_profile_fixture(scope)

      {:ok, live_view, _html} =
        live(conn, ~p"/financial_profiles/#{profile}/edit?field=net_worth")

      assert {:ok, _live, html} =
               live_view
               |> form("#financial_profile-form",
                 financial_profile: %{
                   net_worth: "100000"
                 }
               )
               |> render_submit()
               |> follow_redirect(conn, ~p"/finances")

      assert html =~ "Profil financier mis à jour avec succès"
    end

    test "shows edit title with field name", %{conn: conn, scope: scope} do
      profile = financial_profile_fixture(scope)

      {:ok, _live, html} =
        live(conn, ~p"/financial_profiles/#{profile}/edit?field=current_savings")

      assert html =~ "Épargne actuelle"
    end

    test "ignores invalid field param and shows full form", %{conn: conn, scope: scope} do
      profile = financial_profile_fixture(scope)

      {:ok, _live, html} = live(conn, ~p"/financial_profiles/#{profile}/edit?field=bogus")

      assert html =~ "Épargne actuelle"
      assert html =~ "Dettes actuelles"
      assert html =~ "Statut professionnel"
    end
  end

  describe "Cancel button" do
    test "navigates back to finances", %{conn: conn} do
      {:ok, live_view, _html} = live(conn, ~p"/financial_profiles/new")

      assert has_element?(live_view, "a[href='/finances']")
    end
  end
end
