import Button from "./Button";

// Navbar: top bar that sticks to the top while scrolling.
function Navbar() {
  // Center navigation links
  const links = [
    { label: "Features", href: "#features" },
    { label: "Tokens", href: "#tokens" },
    { label: "Docs", href: "#docs" },
  ];

  return (
    // Sticky and blurred background so it stays readable over the page.
    <header className="sticky top-0 z-30 backdrop-blur-md bg-canvas/60 border-b border-white/5">
      <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
        {/* Logo and brand name */}
        <a href="#" className="flex items-center gap-2">
          <span className="h-7 w-7 rounded-lg bg-gradient-to-br from-accent to-info" />
          <span className="font-bold tracking-tight">MemeSOL</span>
        </a>

        {/* Nav links (hidden on small screens) */}
        <nav className="hidden md:flex items-center gap-8 text-sm text-ink/70">
          {links.map((l) => (
            <a key={l.href} href={l.href} className="hover:text-ink transition-colors">
              {l.label}
            </a>
          ))}
        </nav>

        {/* Sign in and Launch App actions */}
        <div className="flex items-center gap-2">
          <Button variant="ghost" size="sm">Sign in</Button>
          <Button variant="primary" size="sm">Launch App</Button>
        </div>
      </div>
    </header>
  );
}

export default Navbar;
