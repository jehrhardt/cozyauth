defmodule Supapasskeys.WebAuthn do
  use Rustler, otp_app: :supapasskeys, crate: "supapasskeys_webauthn"

  defmodule RelyingParty do
    defstruct name: nil, origin: nil
  end

  defmodule User do
    defstruct id: nil, name: nil, display_name: nil
  end

  # When your NIF is loaded, it will override this function.
  def start_passkey_registration(_relying_party, _user), do: :erlang.nif_error(:nif_not_loaded)

  def finish_passkey_registration(_relying_party, _public_key_credential_json, _state_json),
    do: :erlang.nif_error(:nif_not_loaded)
end
