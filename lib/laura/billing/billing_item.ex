defmodule Laura.Billing.BillingItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "billing_items" do
    belongs_to :health_brand, Laura.Platform.HealthBrand

    field :name, :string
    field :description, :string
    field :item_type, :string
    field :standard_price, :decimal
    field :category, :string
    field :is_active, :boolean, default: true

    timestamps(type: :naive_datetime)
  end

  def changeset(billing_item, attrs) do
    billing_item
    |> cast(attrs, [
      :health_brand_id,
      :name,
      :description,
      :item_type,
      :standard_price,
      :category,
      :is_active
    ])
    |> validate_required([:health_brand_id, :name, :item_type, :standard_price])
  end
end
