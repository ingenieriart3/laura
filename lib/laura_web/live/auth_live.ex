# # # lib/laura_web/live/auth_live.ex
# # defmodule LauraWeb.AuthLive do
# #   use LauraWeb, :live_view
# #   alias Laura.Accounts

# #   @impl true
# #   def mount(_params, _session, socket) do
# #     {:ok,
# #      socket
# #      |> assign(:email, "")
# #      |> assign(:loading, false)
# #      |> assign(:message, nil)
# #      |> assign(:health_brand, get_health_brand_from_host(socket))}
# #   end

# #   @impl true
# #   def handle_event("request_magic_link", %{"email" => email}, socket) do
# #     socket = assign(socket, loading: true, message: nil)

# #     # Get remote IP for security
# #     remote_ip = socket.conn.remote_ip |> :inet.ntoa() |> to_string()

# #     case Accounts.request_magic_link(email, socket.assigns.health_brand.id, remote_ip) do
# #       {:ok, :magic_link_sent} ->
# #         {:noreply,
# #          socket
# #          |> assign(loading: false)
# #          |> assign(message: {:info, "¡Magic link enviado! Revisa tu email."})}

# #       {:error, :rate_limited} ->
# #         {:noreply,
# #          socket
# #          |> assign(loading: false)
# #          |> assign(message: {:error, "Demasiados intentos. Intenta más tarde."})}

# #       {:error, changeset} ->
# #         {:noreply,
# #          socket
# #          |> assign(loading: false)
# #          |> assign(message: {:error, "Error al enviar el magic link."})}
# #     end
# #   end

# #   @impl true
# #   def render(assigns) do
# #     ~H"""
# #     <div class="min-h-screen bg-base-100 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
# #       <div class="max-w-md w-full space-y-8">
# #         <!-- Header -->
# #         <div>
# #           <h2 class="mt-6 text-center text-3xl font-extrabold text-base-content">
# #             Acceder a tu cuenta
# #           </h2>
# #           <p class="mt-2 text-center text-sm text-base-content/60">
# #             Ingresa tu email para recibir un link seguro de acceso
# #           </p>
# #         </div>

# #         <!-- Form -->
# #         <form class="mt-8 space-y-6" phx-submit="request_magic_link">
# #           <div>
# #             <label for="email" class="sr-only">Email</label>
# #             <input
# #               id="email"
# #               name="email"
# #               type="email"
# #               autocomplete="email"
# #               required
# #               class="input input-bordered w-full"
# #               placeholder="tu@clinica.com"
# #               value={@email}
# #               disabled={@loading}
# #             />
# #           </div>

# #           <div>
# #             <button
# #               type="submit"
# #               class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-primary hover:bg-primary-focus focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-focus transition-colors duration-200"
# #               disabled={@loading}
# #             >
# #               <%= if @loading do %>
# #                 <span class="loading loading-spinner"></span>
# #                 Enviando...
# #               <% else %>
# #                 Enviar Magic Link
# #               <% end %>
# #             </button>
# #           </div>

# #           <!-- Messages -->
# #           <div :if={@message}>
# #             <div class={[
# #               "alert",
# #               if(elem(@message, 0) == :info, do: "alert-info", else: "alert-error")
# #             ]}>
# #               <span><%= elem(@message, 1) %></span>
# #             </div>
# #           </div>
# #         </form>

# #         <!-- Security Notice -->
# #         <div class="text-center">
# #           <p class="text-xs text-base-content/40">
# #             🔒 Link válido por 15 minutos · Protegido contra ataques
# #           </p>
# #         </div>
# #       </div>
# #     </div>
# #     """
# #   end

# #   defp get_health_brand_from_host(socket) do
# #     # TODO: Implementar lógica de subdominios
# #     # Por ahora, usar un health_brand por defecto
# #     Laura.Platform.get_health_brand_by_subdomain("demo")
# #   end
# # end

# # lib/laura_web/live/auth_live.ex
# defmodule LauraWeb.AuthLive do
#   use LauraWeb, :live_view
#   alias Laura.Accounts

#   @impl true
#   def mount(_params, _session, socket) do
#     {:ok,
#      socket
#      |> assign(:email, "")
#      |> assign(:loading, false)
#      |> assign(:message, nil)
#      |> assign(:health_brand, get_health_brand_from_host())}
#   end

#   @impl true
#   def handle_event("request_magic_link", %{"email" => email}, socket) do
#     socket = assign(socket, loading: true, message: nil)

#     remote_ip = socket.conn.remote_ip |> :inet.ntoa() |> to_string()

#     case Accounts.request_magic_link(email, socket.assigns.health_brand.id, remote_ip) do
#       {:ok, :magic_link_sent} ->
#         {:noreply,
#          socket
#          |> assign(loading: false)
#          |> assign(message: {:info, "¡Magic link enviado! Revisa tu email."})}

#       {:error, :rate_limited} ->
#         {:noreply,
#          socket
#          |> assign(loading: false)
#          |> assign(message: {:error, "Demasiados intentos. Intenta más tarde."})}

#       {:error, _changeset} ->
#         {:noreply,
#          socket
#          |> assign(loading: false)
#          |> assign(message: {:error, "Error al enviar el magic link."})}
#     end
#   end

#   @impl true
#   def render(assigns) do
#     ~H"""
#     <div class="min-h-screen bg-base-100 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
#       <div class="max-w-md w-full space-y-8">
#         <!-- Header -->
#         <div>
#           <h2 class="mt-6 text-center text-3xl font-extrabold text-base-content">
#             Acceder a tu cuenta
#           </h2>
#           <p class="mt-2 text-center text-sm text-base-content/60">
#             Ingresa tu email para recibir un link seguro de acceso
#           </p>
#         </div>

#         <!-- Form -->
#         <form class="mt-8 space-y-6" phx-submit="request_magic_link">
#           <div>
#             <label for="email" class="sr-only">Email</label>
#             <input
#               id="email"
#               name="email"
#               type="email"
#               autocomplete="email"
#               required
#               class="input input-bordered w-full"
#               placeholder="tu@clinica.com"
#               value={@email}
#               disabled={@loading}
#             />
#           </div>

#           <div>
#             <button
#               type="submit"
#               class="btn btn-primary w-full"
#               disabled={@loading}
#             >
#               <%= if @loading do %>
#                 <span class="loading loading-spinner"></span>
#                 Enviando...
#               <% else %>
#                 Enviar Magic Link
#               <% end %>
#             </button>
#           </div>

#           <!-- Messages -->
#           <div :if={@message}>
#             <div class={[
#               "alert",
#               if(elem(@message, 0) == :info, do: "alert-info", else: "alert-error")
#             ]}>
#               <span><%= elem(@message, 1) %></span>
#             </div>
#           </div>
#         </form>

#         <!-- Security Notice -->
#         <div class="text-center">
#           <p class="text-xs text-base-content/40">
#             🔒 Link válido por 15 minutos · Protegido contra ataques
#           </p>
#         </div>
#       </div>
#     </div>
#     """
#   end

#   defp get_health_brand_from_host do
#     # Por ahora, usar un health_brand por defecto
#     Laura.Platform.get_health_brand_by_subdomain("demo") ||
#       Laura.Platform.create_health_brand(%{name: "Demo", subdomain: "demo"})
#   end
# end

# lib/laura_web/live/auth_live.ex
defmodule LauraWeb.AuthLive do
  use LauraWeb, :live_view
  alias Laura.{Accounts, Platform}

  @impl true
  def mount(_params, _session, socket) do
    health_brand = get_health_brand_from_host()

    {:ok,
     socket
     |> assign(:email, "")
     |> assign(:loading, false)
     |> assign(:message, nil)
     |> assign(:health_brand, health_brand)}
  end

  @impl true
  def handle_event("request_magic_link", %{"email" => email}, socket) do
    socket = assign(socket, loading: true, message: nil)

    remote_ip = socket.conn.remote_ip |> :inet.ntoa() |> to_string()

    case Accounts.request_magic_link(email, socket.assigns.health_brand.id, remote_ip) do
      {:ok, :magic_link_sent} ->
        {:noreply,
         socket
         |> assign(loading: false)
         |> assign(message: {:info, "¡Magic link enviado! Revisa tu email."})}

      {:error, :rate_limited} ->
        {:noreply,
         socket
         |> assign(loading: false)
         |> assign(message: {:error, "Demasiados intentos. Intenta más tarde."})}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> assign(loading: false)
         |> assign(message: {:error, "Error al enviar el magic link."})}
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
