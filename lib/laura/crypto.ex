# # # lib/laura/crypto.ex
# # defmodule Laura.Crypto do
# #   @moduledoc """
# #   Cryptographic utilities for secure token generation and validation.
# #   Enterprise-grade security patterns.
# #   """

# #   @token_length 32
# #   @max_attempts 5

# #   @doc """
# #   Genera token seguro usando :crypto.strong_rand_bytes
# #   """
# #   def generate_secure_token do
# #     :crypto.strong_rand_bytes(@token_length)
# #     |> Base.url_encode64()
# #     |> binary_part(0, @token_length)
# #   end

# #   @doc """
# #   Verifica token con timing-attack protection
# #   """
# #   def secure_token_compare(left, right) when is_binary(left) and is_binary(right) do
# #     if byte_size(left) == byte_size(right) do
# #       :crypto.mac(:hmac, :sha256, "token_compare", left) ==
# #       :crypto.mac(:hmac, :sha256, "token_compare", right)
# #     else
# #       false
# #     end
# #   end

# #   @doc """
# #   Verifica si un token ha expirado
# #   """
# #   def token_expired?(expires_at) when not is_nil(expires_at) do
# #     DateTime.compare(expires_at, DateTime.utc_now()) == :lt
# #   end

# #   def token_expired?(_), do: true
# # end

# # lib/laura/crypto.ex
# defmodule Laura.Crypto do
#   @moduledoc """
#   Cryptographic utilities for secure token generation and validation.
#   """

#   @token_length 32

#   @doc """
#   Genera token seguro usando :crypto.strong_rand_bytes
#   """
#   def generate_secure_token do
#     :crypto.strong_rand_bytes(@token_length)
#     |> Base.url_encode64()
#     |> binary_part(0, @token_length)
#   end

#   @doc """
#   Verifica si un token ha expirado
#   """
#   def token_expired?(expires_at) when not is_nil(expires_at) do
#     DateTime.compare(expires_at, DateTime.utc_now()) == :lt
#   end

#   def token_expired?(_), do: true
# end

# lib/laura/crypto.ex
defmodule Laura.Crypto do
  @moduledoc """
  Cryptographic utilities for secure token generation and validation.
  """

  @token_length 32

  @doc """
  Genera token seguro usando :crypto.strong_rand_bytes
  """
  def generate_secure_token do
    :crypto.strong_rand_bytes(@token_length)
    |> Base.url_encode64()
    |> binary_part(0, @token_length)
  end

  @doc """
  Verifica si un token ha expirado (con NaiveDateTime)
  """
  def token_expired?(expires_at) when not is_nil(expires_at) do
    NaiveDateTime.compare(expires_at, NaiveDateTime.utc_now()) == :lt
  end

  def token_expired?(_), do: true
end
