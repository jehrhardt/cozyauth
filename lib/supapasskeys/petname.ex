defmodule Supapasskeys.Petname do
  use Rustler, otp_app: :supapasskeys, crate: "supapasskeys_petname"

  # When your NIF is loaded, it will override this function.
  def generate_subdomain(), do: :erlang.nif_error(:nif_not_loaded)
end
