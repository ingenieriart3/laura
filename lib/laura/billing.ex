# # lib/laura/billing.ex
# defmodule Laura.Billing do
#   import Ecto.Query, warn: false
#   alias Laura.Repo
#   alias Laura.Platform
#   alias Laura.Billing.SubscriptionPlan
#   alias Laura.Billing.PaymentEvent
#   alias Laura.Platform.HealthBrand

#   # Planes predefinidos
#   @plans [
#     %{
#       name: "Básico",
#       code: "basic",
#       price_monthly: 4900,
#       staff_limit: 1,
#       reminder_limit: 50,
#       features: %{
#         hce: true,
#         reports: false,
#         telemedicine: false,
#         api_access: false
#       },
#       recommended: false
#     },
#     %{
#       name: "Estándar",
#       code: "standard",
#       price_monthly: 14900,
#       staff_limit: 5,
#       reminder_limit: 250,
#       features: %{
#         hce: true,
#         reports: true,
#         telemedicine: false,
#         api_access: false
#       },
#       recommended: true
#     },
#     %{
#       name: "Premium",
#       code: "premium",
#       price_monthly: 29900,
#       staff_limit: nil,
#       reminder_limit: nil,
#       features: %{
#         hce: true,
#         reports: true,
#         telemedicine: true,
#         api_access: true
#       },
#       recommended: false
#     }
#   ]

#   def seed_subscription_plans! do
#     for plan_attrs <- @plans do
#       %SubscriptionPlan{}
#       |> SubscriptionPlan.changeset(plan_attrs)
#       |> Repo.insert!(on_conflict: :nothing, conflict_target: :code)
#     end
#   end

#   def list_subscription_plans do
#     Repo.all(SubscriptionPlan)
#   end

#   def list_public_subscription_plans do
#     SubscriptionPlan
#     |> where([p], p.is_active == true)
#     |> Repo.all()
#   end

#   def get_subscription_plan!(id), do: Repo.get!(SubscriptionPlan, id)

#   # Crear preferencia de pago en MercadoPago
#   def create_mercadopago_preference(health_brand, plan, return_url) do
#     preference_data = %{
#       items: [
#         %{
#           title: "Laura - Plan #{plan.name}",
#           description: "Suscripción mensual",
#           quantity: 1,
#           currency_id: "ARS",
#           unit_price: plan.price_monthly
#         }
#       ],
#       back_urls: %{
#         success: return_url <> "/success",
#         failure: return_url <> "/failure",
#         pending: return_url <> "/pending"
#       },
#       auto_return: "approved",
#       external_reference: health_brand.id,
#       notification_url: System.get_env("MP_WEBHOOK_URL") <> "/webhooks/mercadopago"
#     }

#     case Laura.Billing.MercadoPago.create_preference(preference_data) do
#       {:ok, preference} ->
#         {:ok, preference}
#       {:error, error} ->
#         {:error, error}
#     end
#   end

#   # Procesar webhook de MercadoPago
#   def handle_mercadopago_webhook(payload) do
#     # Verificar la firma del webhook para seguridad
#     case verify_webhook_signature(payload) do
#       true ->
#         process_mercadopago_payment(payload)
#       false ->
#         {:error, :invalid_signature}
#     end
#   end

#   defp process_mercadopago_payment(%{"type" => "payment", "data" => %{"id" => payment_id}}) do
#     # Obtener detalles del pago desde MercadoPago
#     case Laura.Billing.MercadoPago.get_payment(payment_id) do
#       {:ok, payment} ->
#         create_payment_event(payment)

#         case payment["status"] do
#           "approved" ->
#             # Activar suscripción
#             health_brand_id = payment["external_reference"]
#             activate_subscription(health_brand_id, payment)
#           _ ->
#             {:ok, :payment_processed}
#         end
#       {:error, error} ->
#         {:error, error}
#     end
#   end

#   defp create_payment_event(payment) do
#     health_brand_id = payment["external_reference"]

#     %PaymentEvent{}
#     |> PaymentEvent.changeset(%{
#       event_type: "payment",
#       mp_payment_id: payment["id"],
#       mp_merchant_order_id: payment["merchant_order_id"],
#       status: payment["status"],
#       amount: payment["transaction_amount"],
#       metadata: payment,
#       health_brand_id: health_brand_id
#     })
#     |> Repo.insert()
#   end

#   defp activate_subscription(health_brand_id, payment) do
#     health_brand = Platform.get_health_brand!(health_brand_id)

#     period_end = DateTime.utc_now() |> DateTime.add(30, :day)

#     Platform.update_health_brand(health_brand, %{
#       subscription_status: "active",
#       current_period_end: period_end,
#       mp_subscription_id: payment["id"]
#     })
#   end

#   defp verify_webhook_signature(_payload) do
#     # Implementar verificación de firma de MercadoPago
#     true # Placeholder
#   end

#   defp process_mercadopago_payment(%{"type" => "payment", "data" => %{"id" => payment_id}}) do
#     # Obtener detalles del pago desde MercadoPago
#     case Laura.Billing.MercadoPago.get_payment(payment_id) do
#       {:ok, payment} ->
#         # ✅ CORREGIDO: Ahora llamamos a create_payment_event correctamente
#         {:ok, _payment_event} = create_payment_event(payment)

#         case payment["status"] do
#           "approved" ->
#             # Activar suscripción
#             health_brand_id = payment["external_reference"]
#             activate_subscription(health_brand_id, payment)
#           _ ->
#             {:ok, :payment_processed}
#         end
#       {:error, error} ->
#         {:error, error}
#     end
#   end

#   def child_spec(_opts) do
#     %{
#       id: __MODULE__,
#       start: {__MODULE__, :start_link, []},
#       type: :worker,
#       restart: :permanent,
#       shutdown: 500
#     }
#   end

#   def start_link do
#     :ignore
#   end
# end

# lib/laura/billing.ex - VERSIÓN CORREGIDA
defmodule Laura.Billing do
  import Ecto.Query, warn: false
  alias Laura.Repo
  alias Laura.Platform
  alias Laura.Billing.SubscriptionPlan
  alias Laura.Billing.PaymentEvent

  # Planes predefinidos
  @plans [
    %{
      name: "Básico",
      code: "basic",
      price_monthly: 4900,
      staff_limit: 1,
      reminder_limit: 50,
      features: %{
        hce: true,
        reports: false,
        telemedicine: false,
        api_access: false
      },
      recommended: false
    },
    %{
      name: "Estándar",
      code: "standard",
      price_monthly: 14900,
      staff_limit: 5,
      reminder_limit: 250,
      features: %{
        hce: true,
        reports: true,
        telemedicine: false,
        api_access: false
      },
      recommended: true
    },
    %{
      name: "Premium",
      code: "premium",
      price_monthly: 29900,
      staff_limit: nil,
      reminder_limit: nil,
      features: %{
        hce: true,
        reports: true,
        telemedicine: true,
        api_access: true
      },
      recommended: false
    }
  ]

  def seed_subscription_plans! do
    for plan_attrs <- @plans do
      %SubscriptionPlan{}
      |> SubscriptionPlan.changeset(plan_attrs)
      |> Repo.insert!(on_conflict: :nothing, conflict_target: :code)
    end
  end

  def list_subscription_plans do
    Repo.all(SubscriptionPlan)
  end

  def list_public_subscription_plans do
    SubscriptionPlan
    |> where([p], p.is_active == true)
    |> Repo.all()
  end

  def get_subscription_plan!(id), do: Repo.get!(SubscriptionPlan, id)

  # Crear preferencia de pago en MercadoPago
  def create_mercadopago_preference(health_brand, plan, return_url) do
    preference_data = %{
      items: [
        %{
          title: "Laura - Plan #{plan.name}",
          description: "Suscripción mensual",
          quantity: 1,
          currency_id: "ARS",
          unit_price: plan.price_monthly
        }
      ],
      back_urls: %{
        success: return_url <> "/success",
        failure: return_url <> "/failure",
        pending: return_url <> "/pending"
      },
      auto_return: "approved",
      external_reference: health_brand.id,
      notification_url: System.get_env("MP_WEBHOOK_URL") <> "/webhooks/mercadopago"
    }

    case Laura.Billing.MercadoPago.create_preference(preference_data) do
      {:ok, preference} ->
        {:ok, preference}
      {:error, error} ->
        {:error, error}
    end
  end

  # Procesar webhook de MercadoPago
  def handle_mercadopago_webhook(payload) do
    case verify_webhook_signature(payload) do
      true ->
        process_mercadopago_payment(payload)
      false ->
        {:error, :invalid_signature}
    end
  end

  # ✅ SOLO UNA VERSIÓN de esta función - eliminar la duplicada
  defp process_mercadopago_payment(%{"type" => "payment", "data" => %{"id" => payment_id}}) do
    case Laura.Billing.MercadoPago.get_payment(payment_id) do
      {:ok, payment} ->
        {:ok, _payment_event} = create_payment_event(payment)

        case payment["status"] do
          "approved" ->
            health_brand_id = payment["external_reference"]
            activate_subscription(health_brand_id, payment)
          _ ->
            {:ok, :payment_processed}
        end
      {:error, error} ->
        {:error, error}
    end
  end

  defp create_payment_event(payment) do
    health_brand_id = payment["external_reference"]

    %PaymentEvent{}
    |> PaymentEvent.changeset(%{
      event_type: "payment",
      mp_payment_id: payment["id"],
      mp_merchant_order_id: payment["merchant_order_id"],
      status: payment["status"],
      amount: payment["transaction_amount"],
      metadata: payment,
      health_brand_id: health_brand_id
    })
    |> Repo.insert()
  end

  defp activate_subscription(health_brand_id, payment) do
    health_brand = Platform.get_health_brand!(health_brand_id)
    period_end = DateTime.utc_now() |> DateTime.add(30, :day)

    Platform.update_health_brand(health_brand, %{
      subscription_status: "active",
      current_period_end: period_end,
      mp_subscription_id: payment["id"]
    })
  end

  defp verify_webhook_signature(_payload) do
    true # Placeholder
  end

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link, do: :ignore
end
