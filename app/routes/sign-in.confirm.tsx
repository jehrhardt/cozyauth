import { type LoaderFunctionArgs } from "@remix-run/deno";
import { verfiyToken } from "../supabase.server.ts";

export async function loader({ request }: LoaderFunctionArgs) {
  const requestUrl = new URL(request.url);
  const token_hash = requestUrl.searchParams.get("token_hash");
  const type = requestUrl.searchParams.get("type");
  return await verfiyToken(type, token_hash, request);
}
