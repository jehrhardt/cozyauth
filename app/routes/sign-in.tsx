import { Outlet } from "@remix-run/react";
import React from "react";

export default function SignInLayout() {
  return (
    <div>
      <h1>Sign in</h1>
      <Outlet />
    </div>
  );
}
