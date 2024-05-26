defmodule Cozyauth.PasskeysTest do
  use ExUnit.Case

  import Cozyauth.Passkeys

  test "start passkey registration" do
    assert start_passkey_registration() == "Hello world!"
  end
end
