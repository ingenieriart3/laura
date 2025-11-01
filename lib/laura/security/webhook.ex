# defmodule Laura.Security.Webhook do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id

#   schema "webhooks" do
#     belongs_to :health_brand, Laura.Platform.HealthBrand

#     # Configuración del webhook
#     field :name, :string
#     field :url, :string
#     field :secret_key, :string
#     field :events, :map, default: %{}

#     # Estado y configuración
#     field :is_active, :boolean, default: true
#     field :retry_count, :integer, default: 3
#     field :timeout_ms, :integer, default: 5000

#     # Estadísticas
#     field :last_triggered_at, :naive_datetime
#     field :success_count, :integer, default: 0
#     field :failure_count, :integer, default: 0

#     timestamps(type: :naive_datetime)
#   end

#   def changeset(webhook, attrs) do
#     webhook
#     |> cast(attrs, [
#       :health_brand_id, :name, :url, :secret_key, :events, :is_active,
#       :retry_count, :timeout_ms, :last_triggered_at, :success_count, :failure_count
#     ])
#     |> validate_required([:health_brand_id, :name, :url, :secret_key])
#     |> validate_format(:url, ~r/^https?:\/\/.+/)
#   end
# end

defmodule Laura.Security.Webhook do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "webhooks" do
    belongs_to :health_brand, Laura.Platform.HealthBrand

    field :url, :string
    field :event_type, :string
    field :secret, :string
    field :is_active, :boolean, default: true
    field :last_triggered_at, :naive_datetime

    timestamps(type: :naive_datetime)
  end

  def changeset(webhook, attrs) do
    webhook
    |> cast(attrs, [
      :health_brand_id,
      :url,
      :event_type,
      :secret,
      :is_active,
      :last_triggered_at
    ])
    |> validate_required([:health_brand_id, :url, :event_type])
  end
end
