defmodule Laura.Repo.Migrations.CreateBillingItems do
  use Ecto.Migration

  def change do
    create table(:billing_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, references(:health_brands, type: :binary_id, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :description, :text
      add :item_type, :string, null: false  # "consultation", "procedure", "medication", "supply"
      add :standard_price, :decimal, precision: 10, scale: 2, null: false
      add :category, :string
      add :is_active, :boolean, default: true, null: false

      timestamps(type: :naive_datetime)
    end

    create index(:billing_items, [:health_brand_id])
    create unique_index(:billing_items, [:health_brand_id, :name])
    create index(:billing_items, [:item_type])
    create index(:billing_items, [:is_active])
  end
end
