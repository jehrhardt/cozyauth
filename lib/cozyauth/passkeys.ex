defmodule Cozyauth.Passkeys do
  use Rustler, otp_app: :cozyauth, crate: "cozyauth_passkeys"

  # When your NIF is loaded, it will override this function.
  def start_passkey_registration(), do: :erlang.nif_error(:nif_not_loaded)
end
