import Button from "./Button";

function Navbar() {
  const links = [
    { label: "Features", href: "#features" },
    { label: "Tokens", href: "#tokens" },
    { label: "Docs", href: "#docs" },
  ];

  return (
    <header className="sticky top-0 z-30 backdrop-blur-md bg-canvas/60 border-b border-white/5">
      <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
        <a href="#" className="flex items-center gap-2">
          <span className="h-7 w-7 rounded-lg bg-gradient-to-br from-accent to-info" />
          <span className="font-bold tracking-tight">MemeSOL</span>
        </a>

        <nav className="hidden md:flex items-center gap-8 text-sm text-ink/70">
          {links.map((l) => (
            <a key={l.href} href={l.href} className="hover:text-ink transition-colors">
              {l.label}
            </a>
          ))}
        </nav>

        <div className="flex items-center gap-2">
          <Button variant="ghost" size="sm">Sign in</Button>
          <Button variant="primary" size="sm">Launch App</Button>
        </div>
      </div>
    </header>
  );
}

export default Navbar;
