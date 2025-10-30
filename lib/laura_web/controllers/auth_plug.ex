# lib/laura_web/controllers/auth_plug.ex
defmodule LauraWeb.AuthPlug do
  import Plug.Conn
  alias Laura.{Accounts, Repo}

  def init(opts), do: opts

  def call(conn, _opts) do
    staff_id = get_session(conn, :staff_id)

    if staff_id do
      case Accounts.get_staff!(staff_id) do
        nil ->
          conn |> clear_session() |> assign(:current_staff, nil)
        staff ->
          staff_with_associations = Repo.preload(staff, [:health_brand, :staff_role])
          assign(conn, :current_staff, staff_with_associations)
      end
    else
      assign(conn, :current_staff, nil)
    end
  end
end
