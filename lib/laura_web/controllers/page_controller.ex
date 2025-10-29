defmodule LauraWeb.PageController do
  use LauraWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
