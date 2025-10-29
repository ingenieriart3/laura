# lib/laura/security/rate_limiter.ex
defmodule Laura.Security.RateLimiter do
  use GenServer

  # Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def check_rate_limit(key, action_type) do
    GenServer.call(__MODULE__, {:check_rate_limit, key, action_type})
  end

  # Server callbacks
  @impl true
  def init(state) do
    :timer.send_interval(:timer.minutes(1), :cleanup)
    {:ok, state}
  end

  @impl true
  def handle_call({:check_rate_limit, key, action_type}, _from, state) do
    config = get_config(action_type)
    now = System.system_time(:second)
    window_key = {key, action_type, div(now, config.time_window)}

    current_count = Map.get(state, window_key, 0)

    if current_count < config.allowed_attempts do
      new_state = Map.put(state, window_key, current_count + 1)
      {:reply, {:ok, config.allowed_attempts - current_count - 1}, new_state}
    else
      {:reply, {:error, :rate_limited}, state}
    end
  end

  @impl true
  def handle_info(:cleanup, state) do
    now = System.system_time(:second)
    # Limpiar entradas antiguas (más de 1 hora)
    new_state = Enum.filter(state, fn {{_key, _type, window_start}, _count} ->
      now - window_start * 3600 < 7200 # 2 horas
    end) |> Map.new()

    {:noreply, new_state}
  end

  defp get_config(:tenant_registration) do
    %{allowed_attempts: 3, time_window: 3600} # 3 intentos por hora
  end

  defp get_config(:magic_link_requests) do
    %{allowed_attempts: 5, time_window: 900} # 5 intentos cada 15 minutos
  end
end
