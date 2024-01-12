import React from "react";
import { signUp } from "../supabase.server.ts";
import { ActionFunctionArgs, json, redirect } from "@remix-run/deno";
import { Form, useActionData, useNavigation } from "@remix-run/react";

export default function SignIn() {
  const actionData = useActionData<typeof action>();
  const { errors } = actionData || {};
  const navigation = useNavigation();
  const isSubmitting = navigation.formAction === "/sign-in";

  return (
    <Form method="post">
      <label>
        Email:
        {errors?.email && <span>{errors.email}</span>}
        <input name="email" type="email" />
      </label>
      <br />
      <button type="submit">
        {isSubmitting ? "Signing in …" : "Sign in"}
      </button>
    </Form>
  );
}

export async function action({ request }: ActionFunctionArgs) {
  const formData = await request.formData();
  const email = formData.get("email");
  const headers = new Headers();
  const { errors } = await signUp(email, request, headers);
  if (errors) {
    return json({ errors });
  }
  return redirect(`/sign-in/verify?email=${email}`, { headers });
}
