# defmodule Laura.Billing do
#   import Ecto.Query, warn: false
#   alias Laura.Repo
#   alias Laura.Billing.{SubscriptionPlan, PaymentEvent}

#   # Subscription Plans
#   def list_subscription_plans, do: Repo.all(SubscriptionPlan)
#   def get_subscription_plan!(id), do: Repo.get!(SubscriptionPlan, id)
#   def get_subscription_plan_by_code(code), do: Repo.get_by(SubscriptionPlan, code: code)

#   def seed_subscription_plans! do
#     plans = [
#       %{
#         name: "Básico",
#         code: "basic",
#         description: "Perfecto para comenzar",
#         monthly_price: Decimal.new("2990"),
#         yearly_price: Decimal.new("29900"),
#         reminders_included: 100,
#         extra_reminder_price: Decimal.new("5"),
#         features: %{
#           whatsapp_reminders: true,
#           basic_analytics: true,
#           email_support: true
#         },
#         is_active: true
#       },
#       %{
#         name: "Profesional",
#         code: "professional",
#         description: "Para clínicas en crecimiento",
#         monthly_price: Decimal.new("5990"),
#         yearly_price: Decimal.new("59900"),
#         reminders_included: 500,
#         extra_reminder_price: Decimal.new("4"),
#         features: %{
#           whatsapp_reminders: true,
#           advanced_analytics: true,
#           priority_support: true,
#           custom_branding: true
#         },
#         is_active: true
#       },
#       %{
#         name: "Enterprise",
#         code: "enterprise",
#         description: "Para grandes instituciones",
#         monthly_price: Decimal.new("11990"),
#         yearly_price: Decimal.new("119900"),
#         reminders_included: 2000,
#         extra_reminder_price: Decimal.new("3"),
#         features: %{
#           whatsapp_reminders: true,
#           premium_analytics: true,
#           dedicated_support: true,
#           custom_branding: true,
#           api_access: true
#         },
#         is_active: true
#       }
#     ]

#     Enum.each(plans, fn plan_attrs ->
#       case get_subscription_plan_by_code(plan_attrs.code) do
#         nil ->
#           %SubscriptionPlan{}
#           |> SubscriptionPlan.changeset(plan_attrs)
#           |> Repo.insert!()
#         _plan -> :already_exists
#       end
#     end)
#   end

#   # Payment Events
#   def create_payment_event(attrs \\ %{}) do
#     %PaymentEvent{}
#     |> PaymentEvent.changeset(attrs)
#     |> Repo.insert()
#   end

#   def list_payment_events(health_brand_id) do
#     query = from pe in PaymentEvent,
#             where: pe.health_brand_id == ^health_brand_id,
#             order_by: [desc: pe.inserted_at]
#     Repo.all(query)
#   end

#   def list_public_subscription_plans do
#     from(sp in SubscriptionPlan, where: sp.is_active == true)
#     |> Repo.all()
#   end
# end

defmodule Laura.Billing do
  import Ecto.Query, warn: false
  alias Laura.Repo
  alias Laura.Billing.{SubscriptionPlan, PaymentEvent, Invoice}

  # SubscriptionPlans (existente)
  def list_subscription_plans, do: Repo.all(SubscriptionPlan)
  def list_public_subscription_plans do
    query = from sp in SubscriptionPlan,
            where: sp.is_active == true
    Repo.all(query)
  end

  def get_subscription_plan!(id), do: Repo.get!(SubscriptionPlan, id)
  def get_subscription_plan_by_code(code), do: Repo.get_by(SubscriptionPlan, code: code)

  def seed_subscription_plans! do
    plans = [
      %{
        name: "Básico",
        code: "basic",
        description: "Perfecto para comenzar",
        monthly_price: Decimal.new("2990.00"),
        yearly_price: Decimal.new("29900.00"),
        reminders_included: 100,
        extra_reminder_price: Decimal.new("5.00"),
        features: %{
          "basic_analytics" => true,
          "email_support" => true,
          "whatsapp_reminders" => true
        },
        is_active: true
      },
      %{
        name: "Profesional",
        code: "professional",
        description: "Para clínicas en crecimiento",
        monthly_price: Decimal.new("5990.00"),
        yearly_price: Decimal.new("59900.00"),
        reminders_included: 500,
        extra_reminder_price: Decimal.new("4.00"),
        features: %{
          "advanced_analytics" => true,
          "custom_branding" => true,
          "priority_support" => true,
          "whatsapp_reminders" => true
        },
        is_active: true
      },
      %{
        name: "Enterprise",
        code: "enterprise",
        description: "Para grandes instituciones",
        monthly_price: Decimal.new("11990.00"),
        yearly_price: Decimal.new("119900.00"),
        reminders_included: 2000,
        extra_reminder_price: Decimal.new("3.00"),
        features: %{
          "api_access" => true,
          "custom_branding" => true,
          "dedicated_support" => true,
          "premium_analytics" => true,
          "whatsapp_reminders" => true
        },
        is_active: true
      }
    ]

    Enum.each(plans, fn plan_attrs ->
      case get_subscription_plan_by_code(plan_attrs[:code]) do
        nil ->
          %SubscriptionPlan{}
          |> SubscriptionPlan.changeset(plan_attrs)
          |> Repo.insert!()
        _existing ->
          :already_exists
      end
    end)
  end

  # PaymentEvents (existente)
  def list_payment_events(health_brand_id) do
    query = from pe in PaymentEvent,
            where: pe.health_brand_id == ^health_brand_id,
            order_by: [desc: pe.inserted_at]
    Repo.all(query)
  end

  def create_payment_event(attrs \\ %{}) do
    %PaymentEvent{}
    |> PaymentEvent.changeset(attrs)
    |> Repo.insert()
  end

  # Invoices (NUEVO)
  def list_invoices(health_brand_id) do
    query = from i in Invoice,
            where: i.health_brand_id == ^health_brand_id,
            order_by: [desc: i.invoice_date],
            preload: [:patient]
    Repo.all(query)
  end

  def get_invoice!(id), do: Repo.get!(Invoice, id)

  def create_invoice(attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> Repo.insert()
  end

  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  def generate_invoice_number(health_brand_id) do
    year = Date.utc_today().year
    query = from i in Invoice,
            where: i.health_brand_id == ^health_brand_id and fragment("EXTRACT(YEAR FROM invoice_date) = ?", ^year),
            select: count(i.id)

    count = Repo.one(query) || 0
    "F-#{year}-#{String.pad_leading(to_string(count + 1), 4, "0")}"
  end
end
