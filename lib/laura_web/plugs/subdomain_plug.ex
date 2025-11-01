defmodule LauraWeb.Plugs.SubdomainPlug do
  import Plug.Conn
  alias Laura.Platform

  def init(opts), do: opts

  def call(conn, _opts) do
    case extract_subdomain(conn.host) do
      nil ->
        # No subdomain - main domain
        conn
        |> assign(:health_brand, nil)
        |> assign(:subdomain, nil)

      subdomain ->
        case Platform.get_health_brand_by_subdomain(subdomain) do
          nil ->
            # Subdomain not found - podría ser landing page principal
            conn
            |> assign(:health_brand, nil)
            |> assign(:subdomain, subdomain)

          health_brand ->
            # Valid subdomain found
            conn
            |> assign(:health_brand, health_brand)
            |> assign(:subdomain, subdomain)
        end
    end
  end

  defp extract_subdomain(host) do
    # Extract subdomain from host like "demo.laura.ia3.art" or "demo.laura.local"
    case String.split(host, ".") do
      [subdomain, "laura", "ia3", "art"] -> subdomain
      [subdomain, "laura", "localhost"] -> subdomain
      [subdomain, "laura", "local"] -> subdomain
      _ -> nil
    end
  end
end
