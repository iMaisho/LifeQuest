defmodule LifequestWeb.InvestmentsLive.IndexTest do
  use LifequestWeb.ConnCase
  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  test "renders the investment page with both placements", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/investments")
    assert html =~ "Investissements"
    assert html =~ "Livret Croissance"
    assert html =~ "Portefeuille Actions"
    assert html =~ "Garanti"
    assert html =~ "Variable"
  end

  test "redirects when not authenticated" do
    assert {:error, {:redirect, %{to: path}}} = live(build_conn(), ~p"/investments")
    assert path == ~p"/users/log-in"
  end

  test "updates duration when a shortcut button is clicked", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/investments")

    html = live |> element("button[phx-value-years='5']") |> render_click()
    assert html =~ "5 ans"
  end

  test "updates safe placement results when inputs change", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/investments")

    html =
      live
      |> form("form[phx-change='update_sur']", sur: %{initial: "10000", monthly: "100"})
      |> render_change()

    assert html =~ "10"
  end

  test "updates risky placement results when inputs change", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/investments")

    html =
      live
      |> form("form[phx-change='update_risque']", risque: %{initial: "5000", monthly: "200"})
      |> render_change()

    assert html =~ "Pessimiste"
    assert html =~ "Attendu"
    assert html =~ "Optimiste"
  end

  test "shows initial zero results on mount", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/investments")
    assert html =~ "0,00"
  end
end
