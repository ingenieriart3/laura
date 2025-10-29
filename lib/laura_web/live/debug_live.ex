# # lib/laura_web/live/debug_live.ex
# defmodule LauraWeb.DebugLive do
#   use LauraWeb, :live_view

#   def mount(_params, _session, socket) do
#     {:ok, socket}
#   end

#   def render(assigns) do
#     ~H"""
#     <div class="p-8">
#       <h1 class="text-4xl font-bold text-primary mb-4">🔧 Debug de Estilos</h1>

#       <div class="grid gap-4 mb-8">
#         <button class="btn" style="background: red; color: white;">Botón Rojo (Inline)</button>
#         <button class="btn btn-primary">Botón Primary (DaisyUI)</button>
#         <button class="btn btn-secondary">Botón Secondary</button>
#       </div>

#       <div class="p-4 border-2 border-dashed rounded-lg">
#         <h3 class="text-lg font-bold mb-2">Diagnóstico:</h3>
#         <p class="text-success">✅ LiveView Cargado</p>
#         <p class={@css_status}>⏳ Verificando CSS...</p>
#       </div>
#     </div>
#     """
#   end
# end

# lib/laura_web/live/debug_live.ex
defmodule LauraWeb.DebugLive do
  use LauraWeb, :live_view

  def mount(_params, _session, socket) do
    # Inicializar las asignaciones necesarias
    socket = assign(socket, css_status: "⏳ Verificando CSS...")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-4xl font-bold text-primary mb-4">🔧 Debug de Estilos</h1>

      <!-- Botón con estilo inline (siempre funciona) -->
      <button style="padding: 0.5rem 1rem; background: red; color: white; border: none; border-radius: 0.5rem; margin-bottom: 1rem;">
        Botón Rojo (Inline CSS)
      </button>

      <!-- Botones con clases daisyUI -->
      <div class="grid gap-4 mb-8">
        <button class="btn btn-primary">Botón Primary (DaisyUI)</button>
        <button class="btn btn-secondary">Botón Secondary</button>
        <button class="btn btn-accent">Botón Accent</button>
      </div>

      <!-- Cards -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        <div class="card bg-base-200 shadow-xl">
          <div class="card-body">
            <h2 class="card-title">Card Base</h2>
            <p>Si esto tiene fondo gris, Tailwind funciona</p>
          </div>
        </div>

        <div class="card bg-primary text-primary-content shadow-xl">
          <div class="card-body">
            <h2 class="card-title">Card Primary</h2>
            <p>Si esto tiene fondo azul, DaisyUI funciona</p>
          </div>
        </div>
      </div>

      <!-- Diagnóstico -->
      <div class="p-4 border-2 border-dashed rounded-lg bg-base-200">
        <h3 class="text-lg font-bold mb-2">Estado del Sistema:</h3>
        <p class="text-success">✅ LiveView Cargado</p>
        <p class="text-success">✅ CSS Disponible</p>
        <p id="css-check" class="text-warning">⏳ Verificando aplicación de estilos...</p>
      </div>
    </div>

    <script>
      // Verificación automática después de cargar
      setTimeout(() => {
        const daisyBtn = document.querySelector('.btn-primary');
        const inlineBtn = document.querySelector('button[style]');

        if (daisyBtn && inlineBtn) {
          const daisyStyles = window.getComputedStyle(daisyBtn);
          const inlineStyles = window.getComputedStyle(inlineBtn);

          const daisyBg = daisyStyles.backgroundColor;
          const inlineBg = inlineStyles.backgroundColor;

          const statusEl = document.getElementById('css-check');

          if (daisyBg !== inlineBg && daisyBg !== 'rgba(0, 0, 0, 0)' && daisyBg !== 'transparent') {
            statusEl.textContent = '✅ CSS APLICADO - DaisyUI funcionando correctamente';
            statusEl.className = 'text-success';
          } else {
            statusEl.textContent = '❌ CSS NO APLICADO - DaisyUI no funciona. Daisy: ' + daisyBg + ', Inline: ' + inlineBg;
            statusEl.className = 'text-error';
          }
        }
      }, 100);
    </script>
    """
  end
end
