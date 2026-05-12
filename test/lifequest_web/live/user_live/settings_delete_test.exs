defmodule LifequestWeb.UserLive.SettingsDeleteTest do
  use LifequestWeb.ConnCase, async: true

  import Ecto.Query
  import Phoenix.LiveViewTest
  import Lifequest.AccountsFixtures
  import Lifequest.FinancesFixtures

  alias Lifequest.Accounts
  alias Lifequest.Repo
  alias Lifequest.Finances.{Account, FinancialProfile}

  setup %{conn: conn} do
    user = user_fixture()
    scope = user_scope_fixture(user)
    %{conn: log_in_user(conn, user), user: user, scope: scope}
  end

  describe "delete data button" do
    test "renders the delete data button", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/settings")
      assert html =~ "Delete data"
    end

    test "opens the confirmation modal on click", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")
      html = lv |> element("button[phx-value-modal='delete_data']") |> render_click()
      assert html =~ "Yes, delete my data"
    end

    test "deletes financial data and keeps the account", %{conn: conn, user: user, scope: scope} do
      financial_profile_fixture(scope)
      transaction_fixture(scope)

      {:ok, lv, _html} = live(conn, ~p"/users/settings")
      lv |> element("button[phx-value-modal='delete_data']") |> render_click()
      html = lv |> element("button[phx-click='delete_data']") |> render_click()

      assert html =~ "Your data has been deleted."
      assert Accounts.get_user_by_email(user.email)
      assert Repo.all(from a in Account, where: a.user_id == ^user.id) == []
      assert Repo.all(from fp in FinancialProfile, where: fp.user_id == ^user.id) == []
    end
  end

  describe "delete account button" do
    test "renders the delete account button", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/settings")
      assert html =~ "Delete account"
    end

    test "opens the confirmation modal on click", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")
      html = lv |> element("button[phx-value-modal='delete_account']") |> render_click()
      assert html =~ "Yes, delete my account"
    end

    test "deletes the user and redirects to login", %{conn: conn, user: user, scope: scope} do
      financial_profile_fixture(scope)
      transaction_fixture(scope)

      {:ok, lv, _html} = live(conn, ~p"/users/settings")
      lv |> element("button[phx-value-modal='delete_account']") |> render_click()

      assert {:error, {:redirect, %{to: "/users/log-in"}}} =
               lv |> element("button[phx-click='delete_account']") |> render_click()

      refute Accounts.get_user_by_email(user.email)
      assert Repo.all(from a in Account, where: a.user_id == ^user.id) == []
      assert Repo.all(from fp in FinancialProfile, where: fp.user_id == ^user.id) == []
    end
  end
end
