import * as React from "react";
import {
  json,
  type LoaderFunctionArgs,
  type MetaFunction,
} from "@remix-run/deno";
import { requireUser } from "../supabase.server.ts";
import { useLoaderData } from "@remix-run/react";

export const meta: MetaFunction = () => {
  return [
    { title: "Supapasskeys" },
  ];
};

export async function loader({ request }: LoaderFunctionArgs) {
  const user = await requireUser(request);
  return json({ user });
}

export default function Index() {
  const { user } = useLoaderData<typeof loader>();
  return (
    <h1 className="text-3xl font-bold underline">
      Hello {user.email}!
    </h1>
  );
}
