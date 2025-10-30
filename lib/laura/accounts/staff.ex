defmodule Laura.Accounts.Staff do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "staffs" do
    field :email, :string

    # ⚠️ QUITAR esta línea - belongs_to ya crea el campo
    # field :health_brand_id, :binary_id

    # Magic Link Authentication
    field :magic_link_token, :string
    field :magic_link_sent_at, :naive_datetime
    field :magic_link_expires_at, :naive_datetime
    field :magic_link_attempts, :integer, default: 0
    field :last_magic_link_ip, :string

    # Account State
    field :confirmed_at, :naive_datetime
    field :is_active, :boolean, default: true
    field :last_login_at, :naive_datetime
    field :login_count, :integer, default: 0

    # Security & Recovery
    field :reset_token, :string
    field :reset_sent_at, :naive_datetime

    # Relations
    belongs_to :staff_role, Laura.Accounts.StaffRole
    belongs_to :health_brand, Laura.Platform.HealthBrand

    timestamps(type: :naive_datetime)
  end

  def changeset(staff, attrs) do
    staff
    |> cast(attrs, [
      :email, :health_brand_id, :staff_role_id, :magic_link_token,
      :magic_link_sent_at, :magic_link_expires_at, :confirmed_at,
      :is_active, :last_login_at, :login_count, :reset_token, :reset_sent_at
    ])
    |> validate_required([:email, :health_brand_id, :staff_role_id])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> unique_constraint([:email, :health_brand_id])
  end

  def magic_link_changeset(staff, attrs) do
    staff
    |> cast(attrs, [:magic_link_token, :magic_link_sent_at, :magic_link_expires_at, :last_magic_link_ip])
    |> validate_required([:magic_link_token, :magic_link_sent_at, :magic_link_expires_at])
  end
end
