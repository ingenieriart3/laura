# lib/laura_web/controllers/debug_controller.ex
defmodule LauraWeb.DebugController do
  use LauraWeb, :controller

  def test_styles(conn, _params) do
    render(conn, :test_styles)
  end
end
