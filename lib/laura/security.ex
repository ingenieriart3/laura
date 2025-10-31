defmodule Laura.Security do
  import Ecto.Query, warn: false
  alias Laura.Repo
  alias Laura.Security.{ApiKey, Webhook}

  # API Keys
  def list_api_keys(health_brand_id) do
    query = from ak in ApiKey,
            where: ak.health_brand_id == ^health_brand_id,
            order_by: [desc: ak.inserted_at],
            preload: [:staff]
    Repo.all(query)
  end

  def get_api_key!(id), do: Repo.get!(ApiKey, id)

  def create_api_key(attrs \\ %{}) do
    # Generar key segura
    key_prefix = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
    key_secret = :crypto.strong_rand_bytes(32) |> Base.encode64()
    key_hash = :crypto.hash(:sha256, key_secret) |> Base.encode64()

    full_attrs = Map.merge(attrs, %{
      key_prefix: key_prefix,
      key_hash: key_hash
    })

    %ApiKey{}
    |> ApiKey.changeset(full_attrs)
    |> Repo.insert()
    |> case do
      {:ok, api_key} -> {:ok, api_key, "#{key_prefix}_#{key_secret}"}
      error -> error
    end
  end

  def revoke_api_key(%ApiKey{} = api_key) do
    api_key
    |> ApiKey.changeset(%{
      is_active: false,
      revoked_at: NaiveDateTime.utc_now()
    })
    |> Repo.update()
  end

  def validate_api_key(key) when is_binary(key) do
    case String.split(key, "_", parts: 2) do
      [prefix, secret] ->
        key_hash = :crypto.hash(:sha256, secret) |> Base.encode64()

        query = from ak in ApiKey,
                where: ak.key_prefix == ^prefix and ak.key_hash == ^key_hash,
                where: ak.is_active == true,
                where: is_nil(ak.expires_at) or ak.expires_at > ^NaiveDateTime.utc_now(),
                where: is_nil(ak.revoked_at),
                preload: [:health_brand, :staff]

        case Repo.one(query) do
          nil -> {:error, :invalid_key}
          api_key ->
            # Actualizar último uso
            api_key
            |> ApiKey.changeset(%{
              last_used_at: NaiveDateTime.utc_now(),
              usage_count: (api_key.usage_count || 0) + 1
            })
            |> Repo.update!()

            {:ok, api_key}
        end
      _ ->
        {:error, :invalid_format}
    end
  end

  # Webhooks
  def list_webhooks(health_brand_id) do
    query = from w in Webhook,
            where: w.health_brand_id == ^health_brand_id,
            order_by: [desc: w.inserted_at]
    Repo.all(query)
  end

  def get_webhook!(id), do: Repo.get!(Webhook, id)

  def create_webhook(attrs \\ %{}) do
    # Generar secret key para el webhook
    secret_key = :crypto.strong_rand_bytes(32) |> Base.encode64()

    full_attrs = Map.merge(attrs, %{secret_key: secret_key})

    %Webhook{}
    |> Webhook.changeset(full_attrs)
    |> Repo.insert()
    |> case do
      {:ok, webhook} -> {:ok, webhook, secret_key}
      error -> error
    end
  end

  def update_webhook(%Webhook{} = webhook, attrs) do
    webhook
    |> Webhook.changeset(attrs)
    |> Repo.update()
  end

  def trigger_webhook(webhook, event_type, payload) do
    # Lógica para disparar webhook (se integraría con HTTPoison en producción)
    # Por ahora solo registramos el intento
    {:ok, :webhook_triggered}
  end

  # Security utilities
  def generate_secure_token(length \\ 32) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> String.replace(~r/[\+\/]/, "")
    |> String.slice(0, length)
  end

  def hash_secret(secret) do
    :crypto.hash(:sha256, secret)
    |> Base.encode64()
  end
end
