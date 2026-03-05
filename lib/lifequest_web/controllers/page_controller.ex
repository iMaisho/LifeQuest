defmodule LifequestWeb.PageController do
  use LifequestWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
