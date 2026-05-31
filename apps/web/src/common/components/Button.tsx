import type { ButtonHTMLAttributes, ReactNode } from "react";

// Reusable button.
type Variant = "primary" | "secondary" | "ghost";
type Size = "sm" | "md" | "lg";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  size?: Size;
  children: ReactNode;
}

// Color styles for each variant.
const variants: Record<Variant, string> = {
  primary: "bg-accent text-ink hover:brightness-110", // Solid purple, main action
  secondary:
    "bg-ink/5 text-ink border border-ink/10 hover:bg-ink/10 backdrop-blur", // Subtle outlined
  ghost: "text-ink/80 hover:text-ink hover:bg-ink/5", // Transparent, text-only
};

// Height, padding and text size for each size.
const sizes: Record<Size, string> = {
  sm: "h-9 px-4 text-sm",
  md: "h-11 px-5 text-sm",
  lg: "h-13 px-7 text-base",
};

function Button({
  variant = "primary",
  size = "md",
  className = "",
  children,
  ...rest
}: ButtonProps) {
  return (
    // Base styles and chosen variant/size with any extra classes passed in.
    <button
      className={`inline-flex items-center justify-center gap-2 rounded-full font-semibold transition-all duration-200 cursor-pointer focus:outline-none focus-visible:ring-2 focus-visible:ring-accent/60 ${variants[variant]} ${sizes[size]} ${className}`}
      {...rest}
    >
      {children}
    </button>
  );
}

export default Button;
