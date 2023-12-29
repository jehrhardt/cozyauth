import { createRequestHandlerWithStaticFiles } from "@remix-run/deno";
// Import path interpreted by the Remix compiler
import * as build from "@remix-run/dev/server-build";

const remixHandler = createRequestHandlerWithStaticFiles({
  build,
  getLoadContext: () => ({}),
  mode: build.mode,
});

const port = Number(Deno.env.get("PORT")) || 8000;
const nodeEnv = Deno.env.get("NODE_ENV") || "development";

if (nodeEnv === "production") {
  Deno.serve({ port, hostname: "0.0.0.0" }, remixHandler);
} else {
  Deno.serve({ port }, remixHandler);
}
