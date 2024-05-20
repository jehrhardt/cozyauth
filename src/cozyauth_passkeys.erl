-module(cozyauth_passkeys).
-export([add/2]).
-nifs([add/2]).
-on_load(init/0).

init() ->
    ok = erlang:load_nif("priv/native/libcozyauth_passkeys", 0).

add(_, _) ->
    exit(nif_library_not_loaded).
