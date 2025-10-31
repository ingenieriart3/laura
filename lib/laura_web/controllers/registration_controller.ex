# defmodule LauraWeb.RegistrationController do
#   use LauraWeb, :controller
#   alias Laura.{Platform, Accounts, Billing, Repo}
#   alias Laura.Platform.HealthBrand

#   def new(conn, _params) do
#     changeset = Platform.change_health_brand(%HealthBrand{})
#     plans = Billing.list_public_subscription_plans()

#     render(conn, :new,
#       changeset: changeset,
#       plans: plans,
#       current_staff: conn.assigns[:current_staff]
#     )
#   end

#   def create(conn, %{"health_brand" => health_brand_params}) do
#     # Extraer datos del formulario
#     health_brand_attrs = %{
#       name: health_brand_params["name"],
#       subdomain: health_brand_params["subdomain"]
#     }

#     staff_attrs = %{
#       email: health_brand_params["email"],
#       staff_role_name: "admin"
#     }

#     plan_code = health_brand_params["plan_code"] || "basic"

#     case create_health_brand_with_admin(health_brand_attrs, staff_attrs, plan_code) do
#       {:ok, %{health_brand: health_brand, staff: staff}} ->
#         # Enviar magic link de bienvenida
#         {:ok, _} = Accounts.request_magic_link(staff.email, health_brand.subdomain, get_remote_ip(conn))

#         conn
#         |> put_flash(:info, "¡Registro exitoso! Te hemos enviado un enlace de acceso a tu email.")
#         |> redirect(to: "/auth")

#       {:error, :email_already_exists} ->
#         plans = Billing.list_public_subscription_plans()
#         changeset = Platform.change_health_brand(%HealthBrand{}) |> Ecto.Changeset.add_error(:email, "ya está registrado en otra clínica")

#         conn
#         |> put_flash(:error, "Este email ya está registrado en otra clínica.")
#         |> render(:new,
#              changeset: changeset,
#              plans: plans,
#              current_staff: conn.assigns[:current_staff],
#              email_error: true
#            )

#       {:error, :subdomain_already_exists} ->
#         plans = Billing.list_public_subscription_plans()
#         changeset = Platform.change_health_brand(%HealthBrand{}) |> Ecto.Changeset.add_error(:subdomain, "ya está en uso")

#         conn
#         |> put_flash(:error, "Este subdominio ya está en uso. Por favor elige otro.")
#         |> render(:new,
#              changeset: changeset,
#              plans: plans,
#              current_staff: conn.assigns[:current_staff],
#              subdomain_error: true
#            )

#       {:error, :health_brand, changeset, _} ->
#         plans = Billing.list_public_subscription_plans()
#         conn
#         |> put_flash(:error, "Error al crear la clínica. Verifica los datos.")
#         |> render(:new, changeset: changeset, plans: plans, current_staff: conn.assigns[:current_staff])

#       {:error, _reason} ->
#         plans = Billing.list_public_subscription_plans()
#         changeset = Platform.change_health_brand(%HealthBrand{})
#         conn
#         |> put_flash(:error, "Error en el registro. Intenta nuevamente.")
#         |> render(:new, changeset: changeset, plans: plans, current_staff: conn.assigns[:current_staff])
#     end
#   end

#   defp create_health_brand_with_admin(health_brand_attrs, staff_attrs, plan_code) do
#     Repo.transaction(fn ->
#       with {:ok, plan} <- get_plan(plan_code),
#            {:email_available, true} <- {:email_available, email_available?(staff_attrs.email)},
#            {:subdomain_available, true} <- {:subdomain_available, subdomain_available?(health_brand_attrs.subdomain)},
#            {:ok, health_brand} <- create_health_brand(health_brand_attrs, plan.id),
#            {:ok, staff} <- create_admin_staff(health_brand.id, staff_attrs) do
#         %{health_brand: health_brand, staff: staff}
#       else
#         {:email_available, false} ->
#           Repo.rollback(:email_already_exists)

#         {:subdomain_available, false} ->
#           Repo.rollback(:subdomain_already_exists)

#         {:error, :plan_not_found} ->
#           Repo.rollback(:plan_not_found)

#         {:error, changeset} ->
#           Repo.rollback({:health_brand_error, changeset})

#         error ->
#           Repo.rollback(error)
#       end
#     end)
#   end

#   defp get_plan(plan_code) do
#     case Billing.get_subscription_plan_by_code(plan_code) do
#       nil -> {:error, :plan_not_found}
#       plan -> {:ok, plan}
#     end
#   end

#   defp email_available?(email) do
#     case Accounts.get_staff_by_email(email) do
#       {:ok, _staff} -> false
#       {:error, :not_found} -> true
#     end
#   end

#   defp subdomain_available?(subdomain) do
#     case Platform.get_health_brand_by_subdomain(subdomain) do
#       nil -> true
#       _ -> false
#     end
#   end

#   defp create_health_brand(attrs, plan_id) do
#     full_attrs = Map.merge(attrs, %{subscription_plan_id: plan_id})
#     Platform.create_health_brand(full_attrs)
#   end

#   defp create_admin_staff(health_brand_id, %{email: email, staff_role_name: role_name}) do
#     case Accounts.get_staff_role_by_name(role_name) do
#       nil ->
#         {:error, :role_not_found}
#       admin_role ->
#         Accounts.create_staff(%{
#           email: email,
#           health_brand_id: health_brand_id,
#           staff_role_id: admin_role.id,
#           confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
#           is_active: true
#         })
#     end
#   end

#   defp get_remote_ip(conn) do
#     case conn.remote_ip do
#       {a, b, c, d} -> "#{a}.#{b}.#{c}.#{d}"
#       _ -> "unknown"
#     end
#   end
# end

defmodule LauraWeb.RegistrationController do
  use LauraWeb, :controller
  alias Laura.{Platform, Accounts, Billing, Repo}
  alias Laura.Platform.HealthBrand

  def new(conn, _params) do
    changeset = Platform.change_health_brand(%HealthBrand{})
    plans = Billing.list_public_subscription_plans()

    render(conn, :new,
      changeset: changeset,
      plans: plans,
      current_staff: conn.assigns[:current_staff],
      # Inicializar las variables para evitar el KeyError
      email_error: false,
      subdomain_error: false
    )
  end

  def create(conn, %{"health_brand" => health_brand_params}) do
    # Extraer datos del formulario
    health_brand_attrs = %{
      name: health_brand_params["name"],
      subdomain: health_brand_params["subdomain"]
    }

    staff_attrs = %{
      email: health_brand_params["email"],
      staff_role_name: "admin"
    }

    plan_code = health_brand_params["plan_code"] || "basic"

    case create_health_brand_with_admin(health_brand_attrs, staff_attrs, plan_code) do
      {:ok, %{health_brand: health_brand, staff: staff}} ->
        # Enviar magic link de bienvenida
        {:ok, _} = Accounts.request_magic_link(staff.email, health_brand.subdomain, get_remote_ip(conn))

        conn
        |> put_flash(:info, "¡Registro exitoso! Te hemos enviado un enlace de acceso a tu email.")
        |> redirect(to: "/auth")

      {:error, :email_already_exists} ->
        plans = Billing.list_public_subscription_plans()
        changeset = Platform.change_health_brand(%HealthBrand{}) |> Ecto.Changeset.add_error(:email, "ya está registrado en otra clínica")

        conn
        |> put_flash(:error, "Este email ya está registrado en otra clínica.")
        |> render(:new,
             changeset: changeset,
             plans: plans,
             current_staff: conn.assigns[:current_staff],
             email_error: true,
             subdomain_error: false
           )

      {:error, :subdomain_already_exists} ->
        plans = Billing.list_public_subscription_plans()
        changeset = Platform.change_health_brand(%HealthBrand{}) |> Ecto.Changeset.add_error(:subdomain, "ya está en uso")

        conn
        |> put_flash(:error, "Este subdominio ya está en uso. Por favor elige otro.")
        |> render(:new,
             changeset: changeset,
             plans: plans,
             current_staff: conn.assigns[:current_staff],
             email_error: false,
             subdomain_error: true
           )

      {:error, :health_brand, changeset, _} ->
        plans = Billing.list_public_subscription_plans()
        conn
        |> put_flash(:error, "Error al crear la clínica. Verifica los datos.")
        |> render(:new,
             changeset: changeset,
             plans: plans,
             current_staff: conn.assigns[:current_staff],
             email_error: false,
             subdomain_error: false
           )

      {:error, _reason} ->
        plans = Billing.list_public_subscription_plans()
        changeset = Platform.change_health_brand(%HealthBrand{})
        conn
        |> put_flash(:error, "Error en el registro. Intenta nuevamente.")
        |> render(:new,
             changeset: changeset,
             plans: plans,
             current_staff: conn.assigns[:current_staff],
             email_error: false,
             subdomain_error: false
           )
    end
  end

  defp create_health_brand_with_admin(health_brand_attrs, staff_attrs, plan_code) do
    Repo.transaction(fn ->
      with {:ok, plan} <- get_plan(plan_code),
           {:email_available, true} <- {:email_available, email_available?(staff_attrs.email)},
           {:subdomain_available, true} <- {:subdomain_available, subdomain_available?(health_brand_attrs.subdomain)},
           {:ok, health_brand} <- create_health_brand(health_brand_attrs, plan.id),
           {:ok, staff} <- create_admin_staff(health_brand.id, staff_attrs) do
        %{health_brand: health_brand, staff: staff}
      else
        {:email_available, false} ->
          Repo.rollback(:email_already_exists)

        {:subdomain_available, false} ->
          Repo.rollback(:subdomain_already_exists)

        {:error, :plan_not_found} ->
          Repo.rollback(:plan_not_found)

        {:error, changeset} ->
          Repo.rollback({:health_brand_error, changeset})

        error ->
          Repo.rollback(error)
      end
    end)
  end

  defp get_plan(plan_code) do
    case Billing.get_subscription_plan_by_code(plan_code) do
      nil -> {:error, :plan_not_found}
      plan -> {:ok, plan}
    end
  end

  defp email_available?(email) do
    case Accounts.get_staff_by_email(email) do
      {:ok, _staff} -> false
      {:error, :not_found} -> true
    end
  end

  defp subdomain_available?(subdomain) do
    case Platform.get_health_brand_by_subdomain(subdomain) do
      nil -> true
      _ -> false
    end
  end

  defp create_health_brand(attrs, plan_id) do
    full_attrs = Map.merge(attrs, %{subscription_plan_id: plan_id})
    Platform.create_health_brand(full_attrs)
  end

  defp create_admin_staff(health_brand_id, %{email: email, staff_role_name: role_name}) do
    case Accounts.get_staff_role_by_name(role_name) do
      nil ->
        {:error, :role_not_found}
      admin_role ->
        Accounts.create_staff(%{
          email: email,
          health_brand_id: health_brand_id,
          staff_role_id: admin_role.id,
          confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          is_active: true
        })
    end
  end

  defp get_remote_ip(conn) do
    case conn.remote_ip do
      {a, b, c, d} -> "#{a}.#{b}.#{c}.#{d}"
      _ -> "unknown"
    end
  end
end
