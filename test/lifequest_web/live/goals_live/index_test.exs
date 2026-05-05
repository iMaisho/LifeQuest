defmodule LifequestWeb.GoalsLive.IndexTest do
  use LifequestWeb.ConnCase
  import Phoenix.LiveViewTest
  import Lifequest.FinancesFixtures

  setup :register_and_log_in_user

  test "redirects when not authenticated" do
    assert {:error, {:redirect, %{to: path}}} = live(build_conn(), ~p"/goals")
    assert path == ~p"/users/log-in"
  end

  test "shows no-profile warning when financial profile is missing", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/goals")
    assert html =~ "profil financier"
  end

  test "renders the goal form when profile exists", %{conn: conn, scope: scope} do
    financial_profile_fixture(scope)
    {:ok, _live, html} = live(conn, ~p"/goals")
    assert html =~ "Objectifs"
    assert html =~ "Montant nécessaire"
    assert html =~ "Date cible"
    assert html =~ "Votre situation financière"
  end

  test "shows evaluation result on form submit", %{conn: conn, scope: scope} do
    financial_profile_fixture(scope)
    {:ok, live, _html} = live(conn, ~p"/goals")

    future_date = Date.utc_today() |> Date.add(365 * 10) |> Date.to_iso8601()

    html =
      live
      |> form("form[phx-submit='evaluate']",
        goal: %{target_amount: "1000", target_date: future_date}
      )
      |> render_submit()

    assert html =~ "Objectif"
  end

  test "shows error flash for invalid inputs", %{conn: conn, scope: scope} do
    financial_profile_fixture(scope)
    {:ok, live, _html} = live(conn, ~p"/goals")

    past_date = Date.utc_today() |> Date.add(-1) |> Date.to_iso8601()

    html =
      live
      |> form("form[phx-submit='evaluate']",
        goal: %{target_amount: "1000", target_date: past_date}
      )
      |> render_submit()

    assert html =~ "valide"
  end
end
