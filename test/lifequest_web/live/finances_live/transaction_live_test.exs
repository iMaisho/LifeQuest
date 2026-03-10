defmodule LifequestWeb.TransactionLive.FormTest do
  use LifequestWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lifequest.FinancesFixtures

  setup :register_and_log_in_user

  defp create_account(%{scope: scope}) do
    account = account_fixture(scope)
    %{account: account}
  end

  describe "New transaction - income" do
    setup [:create_account]

    test "renders income form with correct title", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/transactions/new?direction=income&income_type=salary")

      assert html =~ "New income"
    end

    test "has direction and income_type as hidden fields", %{conn: conn} do
      {:ok, live_view, _html} =
        live(conn, ~p"/transactions/new?direction=income&income_type=salary")

      assert has_element?(live_view, "input[name='transaction[direction]'][value='income']")
      assert has_element?(live_view, "input[name='transaction[income_type]'][value='salary']")
    end

    test "does not show direction or type select fields", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/transactions/new?direction=income&income_type=salary")

      refute html =~ "Choose a value"
    end

    test "shows account select", %{conn: conn, account: account} do
      {:ok, _live, html} = live(conn, ~p"/transactions/new?direction=income&income_type=salary")

      assert html =~ "Account"
      assert html =~ account.label
    end

    test "creates income transaction and redirects", %{conn: conn, account: account} do
      {:ok, live_view, _html} =
        live(conn, ~p"/transactions/new?direction=income&income_type=salary")

      assert {:ok, _live, html} =
               live_view
               |> form("#transaction-form",
                 transaction: %{
                   label: "My salary",
                   amount: "2500",
                   date: "2026-03-05",
                   is_recurring: true,
                   account_id: account.id
                 }
               )
               |> render_submit()
               |> follow_redirect(conn, ~p"/finances")

      assert html =~ "Transaction created successfully"
    end

    test "shows validation errors on invalid data", %{conn: conn} do
      {:ok, live_view, _html} =
        live(conn, ~p"/transactions/new?direction=income&income_type=salary")

      html =
        live_view
        |> form("#transaction-form",
          transaction: %{
            label: "",
            amount: "",
            date: ""
          }
        )
        |> render_change()

      assert html =~ "can&#39;t be blank"
    end
  end

  describe "New transaction - expense" do
    setup [:create_account]

    test "renders expense form with correct title", %{conn: conn} do
      {:ok, _live, html} =
        live(conn, ~p"/transactions/new?direction=expense&expense_type=essential")

      assert html =~ "New expense"
    end

    test "has direction and expense_type as hidden fields", %{conn: conn} do
      {:ok, live_view, _html} =
        live(conn, ~p"/transactions/new?direction=expense&expense_type=essential")

      assert has_element?(live_view, "input[name='transaction[direction]'][value='expense']")
      assert has_element?(live_view, "input[name='transaction[expense_type]'][value='essential']")
    end

    test "creates expense transaction and redirects", %{conn: conn, account: account} do
      {:ok, live_view, _html} =
        live(conn, ~p"/transactions/new?direction=expense&expense_type=essential")

      assert {:ok, _live, html} =
               live_view
               |> form("#transaction-form",
                 transaction: %{
                   label: "Monthly rent",
                   amount: "800",
                   date: "2026-03-05",
                   is_recurring: true,
                   account_id: account.id
                 }
               )
               |> render_submit()
               |> follow_redirect(conn, ~p"/finances")

      assert html =~ "Transaction created successfully"
    end
  end

  describe "Edit transaction" do
    setup [:create_account]

    test "renders edit form with correct title", %{conn: conn, scope: scope, account: account} do
      transaction =
        transaction_fixture(scope, %{
          direction: :income,
          income_type: :salary,
          label: "My salary",
          amount: "2500",
          account_id: account.id
        })

      {:ok, _live, html} = live(conn, ~p"/transactions/#{transaction}/edit")

      assert html =~ "Edit income"
      assert html =~ "My salary"
    end

    test "updates transaction and redirects", %{conn: conn, scope: scope, account: account} do
      transaction =
        transaction_fixture(scope, %{
          direction: :income,
          income_type: :salary,
          label: "My salary",
          amount: "2500",
          account_id: account.id
        })

      {:ok, live_view, _html} = live(conn, ~p"/transactions/#{transaction}/edit")

      assert {:ok, _live, html} =
               live_view
               |> form("#transaction-form",
                 transaction: %{
                   label: "Updated salary",
                   amount: "3000"
                 }
               )
               |> render_submit()
               |> follow_redirect(conn, ~p"/finances")

      assert html =~ "Transaction updated successfully"
    end
  end

  describe "Cancel button" do
    test "navigates back to finances", %{conn: conn} do
      {:ok, live_view, _html} =
        live(conn, ~p"/transactions/new?direction=income&income_type=salary")

      assert has_element?(live_view, "a[href='/finances']")
    end
  end

  describe "Default behavior" do
    setup [:create_account]

    test "defaults to income when no direction param", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/transactions/new")

      assert html =~ "New income"
    end
  end
end
