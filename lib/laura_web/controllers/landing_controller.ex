# # lib/laura_web/controllers/landing_controller.ex
# defmodule LauraWeb.LandingController do
#   use LauraWeb, :controller

#   def index(conn, _params) do
#     plans = Laura.Billing.list_public_subscription_plans()
#     render(conn, :index, plans: plans)
#   end

#   def pricing(conn, _params) do
#     plans = Laura.Billing.list_public_subscription_plans()
#     render(conn, :pricing, plans: plans)
#   end

#   def features(conn, _params) do
#     render(conn, :features)
#   end

#   def contact(conn, _params) do
#     render(conn, :contact)
#   end
# end

defmodule LauraWeb.LandingController do
  use LauraWeb, :controller
  alias Laura.Billing

  # def index(conn, _params) do
  #   render(conn, :index)
  # end
  def index(conn, _params) do
    plans = Laura.Billing.list_public_subscription_plans()
    render(conn, :index, plans: plans)
  end

  def features(conn, _params) do
    render(conn, :features)
  end

  def pricing(conn, _params) do
    plans = Billing.list_public_subscription_plans()
    render(conn, :pricing, plans: plans, current_staff: conn.assigns[:current_staff])
  end

  def contact(conn, _params) do
    render(conn, :contact)
  end
end
