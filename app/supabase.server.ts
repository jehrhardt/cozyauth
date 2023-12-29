import { ActionFunctionArgs, LoaderFunctionArgs } from "@remix-run/deno";
import { createServerClient, parse, serialize } from "@supabase/ssr";
import { SupabaseClient } from "@supabase/supabase-js";

async function supabaseClient(
  request: ActionFunctionArgs | LoaderFunctionArgs,
  headers: Headers,
  // deno-lint-ignore no-explicit-any
): Promise<SupabaseClient<any, "public", any>> {
  const cookies = parse(request.headers.get("Cookie") ?? "");

  const env = await load();
  const supabaseUrl = env["SUPABASE_URL"];
  const supabaseAnonKey = env["SUPABASE_ANON_KEY"];

  return createServerClient(supabaseUrl, supabaseAnonKey, {
    cookies: {
      get(key) {
        return cookies[key];
      },
      set(key, value, options) {
        headers.append("Set-Cookie", serialize(key, value, options));
      },
      remove(key, options) {
        headers.append("Set-Cookie", serialize(key, "", options));
      },
    },
  });
}
