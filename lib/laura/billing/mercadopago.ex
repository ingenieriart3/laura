# # lib/laura/billing/mercadopago.ex
# defmodule Laura.Billing.MercadoPago do
#   @base_url "https://api.mercadopago.com"

#   def create_preference(preference_data) do
#     headers = [
#       {"Authorization", "Bearer #{access_token()}"},
#       {"Content-Type", "application/json"}
#     ]

#     body = Jason.encode!(preference_data)

#     case HTTPoison.post("#{@base_url}/checkout/preferences", body, headers) do
#       {:ok, %{status_code: 200, body: body}} ->
#         {:ok, Jason.decode!(body)}
#       {:ok, %{status_code: status_code, body: body}} ->
#         {:error, "HTTP #{status_code}: #{body}"}
#       {:error, error} ->
#         {:error, error}
#     end
#   end

#   def get_payment(payment_id) do
#     headers = [
#       {"Authorization", "Bearer #{access_token()}"}
#     ]

#     case HTTPoison.get("#{@base_url}/v1/payments/#{payment_id}", headers) do
#       {:ok, %{status_code: 200, body: body}} ->
#         {:ok, Jason.decode!(body)}
#       {:ok, %{status_code: status_code, body: body}} ->
#         {:error, "HTTP #{status_code}: #{body}"}
#       {:error, error} ->
#         {:error, error}
#     end
#   end

#   defp access_token do
#     Application.get_env(:laura, :mercadopago)[:access_token]
#   end
# end

# lib/laura/billing/mercadopago.ex
defmodule Laura.Billing.MercadoPago do
  @base_url "https://api.mercadopago.com"

  def create_preference(preference_data) do
    headers = [
      {"Authorization", "Bearer #{access_token()}"},
      {"Content-Type", "application/json"}
    ]

    body = Jason.encode!(preference_data)

    case HTTPoison.post("#{@base_url}/checkout/preferences", body, headers) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}
      {:ok, %{status_code: status_code, body: body}} ->
        {:error, "HTTP #{status_code}: #{body}"}
      {:error, error} ->
        {:error, error}
    end
  end

  def get_payment(payment_id) do
    headers = [
      {"Authorization", "Bearer #{access_token()}"}
    ]

    case HTTPoison.get("#{@base_url}/v1/payments/#{payment_id}", headers) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}
      {:ok, %{status_code: status_code, body: body}} ->
        {:error, "HTTP #{status_code}: #{body}"}
      {:error, error} ->
        {:error, error}
    end
  end

  defp access_token do
    Application.get_env(:laura, :mercadopago)[:access_token] || "TEST-ACCESS-TOKEN"
  end
end
