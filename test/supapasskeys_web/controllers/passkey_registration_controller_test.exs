defmodule SupapasskeysWeb.PasskeyRegistrationControllerTest do
  use SupapasskeysWeb.ConnCase

  import Supapasskeys.PasskeysFixtures

  alias Supapasskeys.Passkeys.PasskeyRegistration

  @create_attrs %{
    state: "some state",
    user_id: "7488a646-e31f-11e4-aace-600308960662"
  }
  @update_attrs %{
    state: "some updated state",
    user_id: "7488a646-e31f-11e4-aace-600308960668"
  }
  @invalid_attrs %{state: nil, user_id: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all passkey_registriations", %{conn: conn} do
      conn = get(conn, ~p"/api/passkey_registriations")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create passkey_registration" do
    test "renders passkey_registration when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/passkey_registriations", passkey_registration: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/passkey_registriations/#{id}")

      assert %{
               "id" => ^id,
               "state" => "some state",
               "user_id" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/passkey_registriations", passkey_registration: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update passkey_registration" do
    setup [:create_passkey_registration]

    test "renders passkey_registration when data is valid", %{conn: conn, passkey_registration: %PasskeyRegistration{id: id} = passkey_registration} do
      conn = put(conn, ~p"/api/passkey_registriations/#{passkey_registration}", passkey_registration: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/passkey_registriations/#{id}")

      assert %{
               "id" => ^id,
               "state" => "some updated state",
               "user_id" => "7488a646-e31f-11e4-aace-600308960668"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, passkey_registration: passkey_registration} do
      conn = put(conn, ~p"/api/passkey_registriations/#{passkey_registration}", passkey_registration: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete passkey_registration" do
    setup [:create_passkey_registration]

    test "deletes chosen passkey_registration", %{conn: conn, passkey_registration: passkey_registration} do
      conn = delete(conn, ~p"/api/passkey_registriations/#{passkey_registration}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/passkey_registriations/#{passkey_registration}")
      end
    end
  end

  defp create_passkey_registration(_) do
    passkey_registration = passkey_registration_fixture()
    %{passkey_registration: passkey_registration}
  end
end
