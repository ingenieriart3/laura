defmodule Laura.Repo.Migrations.CreatePaymentIntegrations do
  use Ecto.Migration

  def change do
    create table(:payment_integrations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, references(:health_brands, type: :binary_id, on_delete: :delete_all), null: false
      add :provider, :string, null: false  # "mercadopago", "stripe"
      add :access_token, :text
      add :public_key, :string
      add :is_active, :boolean, default: false, null: false
      add :webhook_url, :string
      add :metadata, :map, default: %{}

      timestamps(type: :naive_datetime)
    end

    create index(:payment_integrations, [:health_brand_id])
    create unique_index(:payment_integrations, [:health_brand_id, :provider])
    create index(:payment_integrations, [:is_active])
  end
end
