"use client";

import Button from "./Button";
import type { ComponentProps } from "react";

interface ScrollButtonProps extends ComponentProps<typeof Button> {
  targetId: string;
}

export default function ScrollButton({
  targetId,
  ...props
}: ScrollButtonProps) {
  return (
    <Button
      onClick={() =>
        document
          .getElementById(targetId)
          ?.scrollIntoView({ behavior: "smooth" })
      }
      {...props}
    />
  );
}
