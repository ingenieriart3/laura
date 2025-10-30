# # # lib/laura/accounts/staff.ex
# # defmodule Laura.Accounts.Staff do
# #   use Ecto.Schema
# #   import Ecto.Changeset

# #   @primary_key {:id, :binary_id, autogenerate: true}
# #   @foreign_key_type :binary_id

# #   schema "staffs" do
# #     field :email, :string
# #     field :first_name, :string
# #     field :last_name, :string
# #     field :password_hash, :string
# #     field :confirmed_at, :naive_datetime
# #     field :magic_link_token, :string
# #     field :magic_link_sent_at, :naive_datetime

# #     belongs_to :health_brand, Laura.Platform.HealthBrand
# #     belongs_to :staff_role, Laura.Accounts.StaffRole

# #     timestamps()
# #   end

# #   def changeset(staff, attrs) do
# #     staff
# #     |> cast(attrs, [
# #       :email, :first_name, :last_name, :health_brand_id, :staff_role_id
# #     ])
# #     |> validate_required([:email, :health_brand_id])
# #     |> unique_constraint(:email)
# #     |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
# #   end

# #   def registration_changeset(staff, attrs) do
# #     staff
# #     |> changeset(attrs)
# #     |> put_change(:magic_link_token, generate_token())
# #     |> put_change(:magic_link_sent_at, NaiveDateTime.utc_now())
# #   end

# #   defp generate_token, do: :crypto.strong_rand_bytes(32) |> Base.url_encode64()
# # end

# # lib/laura/accounts/staff.ex
# defmodule Laura.Accounts.Staff do
#   use Ecto.Schema
#   import Ecto.Changeset
#   alias Laura.Crypto

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id

#   schema "staffs" do
#     # Core fields
#     field :email, :string
#     field :first_name, :string
#     field :last_name, :string

#     # Magic Link Security
#     field :magic_link_token, :string
#     field :magic_link_sent_at, :utc_datetime
#     field :magic_link_expires_at, :utc_datetime
#     field :magic_link_attempts, :integer, default: 0
#     field :last_magic_link_ip, :string

#     # Account state
#     field :confirmed_at, :utc_datetime
#     field :is_active, :boolean, default: true
#     field :last_login_at, :utc_datetime
#     field :login_count, :integer, default: 0

#     # Security
#     field :password_hash, :string
#     field :reset_token, :string
#     field :reset_sent_at, :utc_datetime

#     # Relations
#     belongs_to :health_brand, Laura.Platform.HealthBrand
#     belongs_to :staff_role, Laura.Accounts.StaffRole

#     # Timestamps
#     timestamps(type: :utc_datetime)
#   end

#   @doc """
#   Changeset para registro con validaciones enterprise
#   """
#   def registration_changeset(staff, attrs, health_brand) do
#     staff
#     |> cast(attrs, [:email, :first_name, :last_name])
#     |> validate_required([:email, :health_brand_id])
#     |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
#     |> validate_length(:email, max: 160)
#     |> unique_constraint(:email, name: :staffs_email_health_brand_id_index)
#     |> put_change(:health_brand_id, health_brand.id)
#     |> put_change(:is_active, true)
#     |> generate_magic_link_token()
#   end

#   @doc """
#   Changeset para generar magic link con seguridad reforzada
#   """
#   def magic_link_changeset(staff, remote_ip) do
#     expires_at = DateTime.utc_now() |> DateTime.add(15, :minute)

#     staff
#     |> change()
#     |> put_change(:magic_link_token, Crypto.generate_secure_token())
#     |> put_change(:magic_link_sent_at, DateTime.utc_now())
#     |> put_change(:magic_link_expires_at, expires_at)
#     |> put_change(:magic_link_attempts, 0)
#     |> put_change(:last_magic_link_ip, remote_ip)
#   end

#   @doc """
#   Changeset para confirmar login exitoso
#   """
#   def confirm_login_changeset(staff, remote_ip) do
#     staff
#     |> change()
#     |> put_change(:confirmed_at, DateTime.utc_now())
#     |> put_change(:last_login_at, DateTime.utc_now())
#     |> put_change(:login_count, staff.login_count + 1)
#     |> put_change(:magic_link_token, nil)
#     |> put_change(:magic_link_expires_at, nil)
#     |> put_change(:last_magic_link_ip, remote_ip)
#   end

#   defp generate_magic_link_token(changeset) do
#     case get_change(changeset, :magic_link_token) do
#       nil -> put_change(changeset, :magic_link_token, Crypto.generate_secure_token())
#       _ -> changeset
#     end
#   end
# end

# lib/laura/accounts/staff.ex
# lib/laura/accounts/staff.ex
defmodule Laura.Accounts.Staff do
  use Ecto.Schema
  import Ecto.Changeset
  alias Laura.Crypto

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "staffs" do
    # Core fields
    field :email, :string
    field :first_name, :string
    field :last_name, :string

    # Magic Link Security
    field :magic_link_token, :string
    field :magic_link_sent_at, :naive_datetime
    field :magic_link_expires_at, :naive_datetime
    field :magic_link_attempts, :integer, default: 0
    field :last_magic_link_ip, :string

    # Account state
    field :confirmed_at, :naive_datetime
    field :is_active, :boolean, default: true
    field :last_login_at, :naive_datetime
    field :login_count, :integer, default: 0

    # Security
    field :password_hash, :string
    field :reset_token, :string
    field :reset_sent_at, :naive_datetime

    # Relations
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :staff_role, Laura.Accounts.StaffRole

    # ✅ CAMBIAR timestamps también
    timestamps(type: :naive_datetime)
  end

  @doc """
  Changeset para registro con validaciones enterprise
  """
  def registration_changeset(staff, attrs, health_brand) do
    staff
    |> cast(attrs, [:email, :first_name, :last_name])
    |> validate_required([:email, :health_brand_id])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email, name: :staffs_email_health_brand_id_index)
    |> put_change(:health_brand_id, health_brand.id)
    |> put_change(:is_active, true)
    |> generate_magic_link_token()
  end

  @doc """
  Changeset para generar magic link con seguridad reforzada
  """
  def magic_link_changeset(staff, remote_ip) do
    expires_at = NaiveDateTime.utc_now() |> NaiveDateTime.add(15, :minute)

    staff
    |> change()
    |> put_change(:magic_link_token, Crypto.generate_secure_token())
    |> put_change(:magic_link_sent_at, NaiveDateTime.utc_now())
    |> put_change(:magic_link_expires_at, expires_at)
    |> put_change(:magic_link_attempts, 0)
    |> put_change(:last_magic_link_ip, remote_ip)
  end

  @doc """
  Changeset para confirmar login exitoso
  """
  def confirm_login_changeset(staff, remote_ip) do
    staff
    |> change()
    |> put_change(:confirmed_at, NaiveDateTime.utc_now())
    |> put_change(:last_login_at, NaiveDateTime.utc_now())
    |> put_change(:login_count, staff.login_count + 1)
    |> put_change(:magic_link_token, nil)
    |> put_change(:magic_link_expires_at, nil)
    |> put_change(:last_magic_link_ip, remote_ip)
  end

  defp generate_magic_link_token(changeset) do
    case get_change(changeset, :magic_link_token) do
      nil -> put_change(changeset, :magic_link_token, Crypto.generate_secure_token())
      _ -> changeset
    end
  end
end
