defmodule LauraWeb.AuthLive do
  use LauraWeb, :live_view
  alias Laura.Accounts

  def mount(_params, _session, socket) do
    health_brand = get_health_brand_from_host()

    # Obtener y guardar la IP durante el mount
    remote_ip = get_remote_ip_from_connect_info(socket)

    {:ok,
     socket
     |> assign(
       email: "",
       loading: false,
       message: nil,
       health_brand: health_brand,
       remote_ip: remote_ip
     )}
  end

  def handle_event("request_magic_link", %{"email" => email}, socket) do
    # Usar la IP guardada en los assigns
    remote_ip = socket.assigns.remote_ip

    socket = assign(socket, loading: true, email: email)

    case Accounts.request_magic_link(email, socket.assigns.health_brand.subdomain, remote_ip) do
      {:ok, :magic_link_sent} ->
        {:noreply,
         socket
         |> assign(loading: false, message: "¡Enlace mágico enviado! Revisa tu email.")
         |> put_flash(:info, "Te hemos enviado un enlace de acceso a tu email.")}

      {:error, :not_found} ->
        {:noreply,
         socket
         |> assign(loading: false, message: "Email no encontrado para esta organización.")
         |> put_flash(:error, "No encontramos una cuenta con ese email.")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> assign(loading: false, message: "Error al enviar el enlace. Intenta nuevamente.")
         |> put_flash(:error, "Error al enviar el enlace de acceso.")}
    end
  end

  # Obtener IP desde connect_info durante el mount
  defp get_remote_ip_from_connect_info(socket) do
    case get_connect_info(socket, :peer_data) do
      %{address: {a, b, c, d}} -> "#{a}.#{b}.#{c}.#{d}"
      _ -> "unknown"
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-100 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div class="max-w-md w-full space-y-8">
        <!-- Header -->
        <div>
          <h2 class="mt-6 text-center text-3xl font-extrabold text-base-content">
            Acceder a tu cuenta
          </h2>
          <p class="mt-2 text-center text-sm text-base-content/60">
            Ingresa tu email para recibir un link seguro de acceso
          </p>
        </div>

        <!-- Form -->
        <form class="mt-8 space-y-6" phx-submit="request_magic_link">
        <%= if @message do %>
          <div class="p-4 rounded-lg bg-blue-50 border border-blue-200">
            <p class="text-blue-800"><%= @message %></p>
          </div>
        <% end %>
          <div>
            <label for="email" class="sr-only">Email</label>
            <input
              id="email"
              name="email"
              type="email"
              autocomplete="email"
              required
              class="input input-bordered w-full"
              placeholder="tu@clinica.com"
              value={@email}
              disabled={@loading}
            />
          </div>

          <div>
            <button
              type="submit"
              class="btn btn-primary w-full"
              disabled={@loading}
            >
              <%= if @loading do %>
                <span class="loading loading-spinner"></span>
                Enviando...
              <% else %>
                Enviar Magic Link
              <% end %>
            </button>
          </div>

          <!-- Messages -->
          <div :if={@message}>
            <div class={[
              "alert",
              if(elem(@message, 0) == :info, do: "alert-info", else: "alert-error")
            ]}>
              <span><%= elem(@message, 1) %></span>
            </div>
          </div>
        </form>

        <!-- Security Notice -->
        <div class="text-center">
          <p class="text-xs text-base-content/40">
            🔒 Link válido por 15 minutos · Protegido contra ataques
          </p>
        </div>
      </div>
    </div>
    """
  end

  # defp get_health_brand_from_host do
  #   # Por ahora, usar un health_brand por defecto
  #   case Platform.get_health_brand_by_subdomain("demo") do
  #     nil ->
  #       # Crear brand demo si no existe
  #       {:ok, brand} = Platform.create_health_brand(%{
  #         name: "Clínica Demo",
  #         subdomain: "demo"
  #       })
  #       brand
  #     brand ->
  #       brand
  #   end
  # end
  # defp get_health_brand_from_host do
  #   # Por ahora, usar el primer health_brand que exista
  #   case Laura.Platform.list_health_brands() do
  #     [brand | _] -> brand
  #     [] ->
  #       # Crear brand demo si no existe ninguno
  #       {:ok, brand} = Laura.Platform.create_health_brand(%{
  #         name: "Clínica Demo",
  #         subdomain: "demo"
  #       })
  #       brand
  #   end
  # end

  # En lib/laura_web/live/auth_live.ex - solución temporal
defp get_health_brand_from_host do
  # Usar brand existente sin crear uno nuevo
  case Laura.Platform.list_health_brands() do
    [brand | _] -> brand
    [] ->
      # Brand mínimo sin campos datetime problemáticos
      {:ok, brand} = Laura.Platform.create_health_brand(%{
        name: "Clínica Demo",
        subdomain: "demo",
        is_active: true,
        subscription_status: "trial"
        # ❌ NO incluir trial_activated_at, trial_ends_at, etc.
      })
      brand
  end
end
end
