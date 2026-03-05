defmodule LifequestWeb.IncomeStreamLiveTest do
  use LifequestWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lifequest.FinancesFixtures

  @create_attrs %{label: "some label", type: :salary, amount: "120.5", frequency: :weekly, start_date: "2026-03-04", end_date: "2026-03-04", is_active: true}
  @update_attrs %{label: "some updated label", type: :freelance, amount: "456.7", frequency: :monthly, start_date: "2026-03-05", end_date: "2026-03-05", is_active: false}
  @invalid_attrs %{label: nil, type: nil, amount: nil, frequency: nil, start_date: nil, end_date: nil, is_active: false}

  setup :register_and_log_in_user

  defp create_income_stream(%{scope: scope}) do
    income_stream = income_stream_fixture(scope)

    %{income_stream: income_stream}
  end

  describe "Index" do
    setup [:create_income_stream]

    test "lists all income_streams", %{conn: conn, income_stream: income_stream} do
      {:ok, _index_live, html} = live(conn, ~p"/income_streams")

      assert html =~ "Listing Income streams"
      assert html =~ income_stream.label
    end

    test "saves new income_stream", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/income_streams")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Income stream")
               |> render_click()
               |> follow_redirect(conn, ~p"/income_streams/new")

      assert render(form_live) =~ "New Income stream"

      assert form_live
             |> form("#income_stream-form", income_stream: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#income_stream-form", income_stream: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/income_streams")

      html = render(index_live)
      assert html =~ "Income stream created successfully"
      assert html =~ "some label"
    end

    test "updates income_stream in listing", %{conn: conn, income_stream: income_stream} do
      {:ok, index_live, _html} = live(conn, ~p"/income_streams")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#income_streams-#{income_stream.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/income_streams/#{income_stream}/edit")

      assert render(form_live) =~ "Edit Income stream"

      assert form_live
             |> form("#income_stream-form", income_stream: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#income_stream-form", income_stream: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/income_streams")

      html = render(index_live)
      assert html =~ "Income stream updated successfully"
      assert html =~ "some updated label"
    end

    test "deletes income_stream in listing", %{conn: conn, income_stream: income_stream} do
      {:ok, index_live, _html} = live(conn, ~p"/income_streams")

      assert index_live |> element("#income_streams-#{income_stream.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#income_streams-#{income_stream.id}")
    end
  end

  describe "Show" do
    setup [:create_income_stream]

    test "displays income_stream", %{conn: conn, income_stream: income_stream} do
      {:ok, _show_live, html} = live(conn, ~p"/income_streams/#{income_stream}")

      assert html =~ "Show Income stream"
      assert html =~ income_stream.label
    end

    test "updates income_stream and returns to show", %{conn: conn, income_stream: income_stream} do
      {:ok, show_live, _html} = live(conn, ~p"/income_streams/#{income_stream}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/income_streams/#{income_stream}/edit?return_to=show")

      assert render(form_live) =~ "Edit Income stream"

      assert form_live
             |> form("#income_stream-form", income_stream: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#income_stream-form", income_stream: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/income_streams/#{income_stream}")

      html = render(show_live)
      assert html =~ "Income stream updated successfully"
      assert html =~ "some updated label"
    end
  end
end
