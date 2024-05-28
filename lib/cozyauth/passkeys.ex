defmodule Cozyauth.Passkeys do
  use Rustler, otp_app: :cozyauth, crate: "cozyauth_passkeys"

  defmodule RelyingParty do
    @enforce_keys [:domain, :name]
    defstruct [:domain, :name]
  end

  defmodule User do
    @enforce_keys [:id, :name, :display_name]
    defstruct [:id, :name, :display_name]
  end

  # When your NIF is loaded, it will override this function.
  def start_passkey_registration(_user, _relying_party),
    do: :erlang.nif_error(:nif_not_loaded)
end
