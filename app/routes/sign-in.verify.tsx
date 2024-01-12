import React from "react";
import { useSearchParams } from "@remix-run/react";

export default function SignInVerify() {
  const [searchParams] = useSearchParams();
  const email = searchParams.get("email");

  return (
    <p>
      A sign in link has been sent to {email}. Click the link to sign in.
    </p>
  );
}
