defmodule LifequestWeb.PageControllerTest do
  use LifequestWeb.ConnCase

  test "GET / redirects unauthenticated user to login", %{conn: conn} do
    conn = get(conn, ~p"/dashboard")
    assert redirected_to(conn) == ~p"/users/log-in"
  end
end
