# lib/laura/accounts/staff.ex
defmodule Laura.Accounts.Staff do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "staffs" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password_hash, :string
    field :confirmed_at, :naive_datetime
    field :magic_link_token, :string
    field :magic_link_sent_at, :naive_datetime

    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :staff_role, Laura.Accounts.StaffRole

    timestamps()
  end

  def changeset(staff, attrs) do
    staff
    |> cast(attrs, [
      :email, :first_name, :last_name, :health_brand_id, :staff_role_id
    ])
    |> validate_required([:email, :health_brand_id])
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
  end

  def registration_changeset(staff, attrs) do
    staff
    |> changeset(attrs)
    |> put_change(:magic_link_token, generate_token())
    |> put_change(:magic_link_sent_at, NaiveDateTime.utc_now())
  end

  defp generate_token, do: :crypto.strong_rand_bytes(32) |> Base.url_encode64()
end
