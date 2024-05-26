defmodule Cozyauth.Passkeys do
  use Rustler, otp_app: :cozyauth, crate: "cozyauth_passkeys"

  # When your NIF is loaded, it will override this function.
  def start_passkey_registration(_user_id, _user_name, _user_display_name),
    do: :erlang.nif_error(:nif_not_loaded)
end
