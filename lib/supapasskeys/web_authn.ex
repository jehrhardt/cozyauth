defmodule Supapasskeys.WebAuthn do
  use Rustler, otp_app: :supapasskeys, crate: "supapasskeys_webauthn"

  defmodule RelyingParty do
    @type t :: %__MODULE__{id: String.t(), name: String.t(), origin: String.t()}
    defstruct id: nil, name: nil, origin: nil
  end

  defmodule User do
    @type t :: %__MODULE__{id: String.t(), name: String.t(), display_name: String.t()}
    defstruct id: nil, name: nil, display_name: nil
  end

  defmodule RegistrationRequest do
    @type t :: %__MODULE__{
            creation_options_json: String.t(),
            passkey_registration: binary()
          }
    defstruct creation_options_json: nil, passkey_registration: nil
  end

  # When your NIF is loaded, it will override this function.
  @spec start_passkey_registration(RelyingParty.t(), User.t()) ::
          {:ok, RegistrationRequest.t()} | {:error, Exception.t()}
  def start_passkey_registration(_relying_party, _user), do: :erlang.nif_error(:nif_not_loaded)
end
