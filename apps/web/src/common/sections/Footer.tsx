import Button from "../components/Button";

function Footer() {
  const sections = [
    {
      title: "Product",
      links: ["Features", "Tokens", "Roadmap", "Changelog"],
    },
    {
      title: "Developers",
      links: ["Docs", "API", "GitHub", "Status"],
    },
    {
      title: "Company",
      links: ["About", "Blog", "Careers", "Contact"],
    },
  ];

  return (
    <footer className="relative border-t border-white/5">
      <div className="max-w-6xl mx-auto px-6 pt-20 pb-12">
        <div className="relative rounded-3xl border border-white/10 bg-gradient-to-br from-accent/15 via-info/10 to-transparent p-10 sm:p-14 overflow-hidden">
          <div className="relative grid md:grid-cols-[1fr_auto] gap-8 items-center">
            <div>
              <h3 className="text-3xl sm:text-4xl font-bold tracking-tight">
                Your tokens. Your transfers. Your history.
              </h3>
              <p className="mt-3 text-ink/70 max-w-lg">
                Download MemeSOL on iOS and start managing your Solana tokens
                with a wallet built for clarity.
              </p>
            </div>
            <div className="flex gap-3">
              <Button size="lg">App Store</Button>
            </div>
          </div>
        </div>

        <div className="mt-16 grid md:grid-cols-[1.5fr_repeat(3,1fr)] gap-10">
          <div>
            <div className="flex items-center gap-2">
              <span className="h-7 w-7 rounded-lg bg-gradient-to-br from-accent to-info" />
              <span className="font-bold tracking-tight">MemeSOL</span>
            </div>
            <p className="mt-4 text-sm text-ink/60 max-w-xs">
              Manage every token with total confidence.
            </p>
          </div>

          {sections.map((section) => (
            <div key={section.title}>
              <p className="text-sm font-semibold text-ink">{section.title}</p>
              <ul className="mt-4 space-y-2.5">
                {section.links.map((link) => (
                  <li key={link}>
                    <a
                      href="#"
                      className="text-sm text-ink/60 hover:text-ink transition-colors"
                    >
                      {link}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="mt-12 pt-8 border-t border-white/5 flex flex-col sm:flex-row justify-between items-center gap-4 text-xs text-ink/50">
          <p>© 2026 MemeSOL, Inc. All Rights Reserved.</p>
          <div className="flex gap-6">        
            <a href="#" className="hover:text-ink transition-colors">Privacy</a>
            <a href="#" className="hover:text-ink transition-colors">Terms</a>
            <a href="#" className="hover:text-ink transition-colors">Security</a>
          </div>
        </div>
      </div>
    </footer>
  );
}

export default Footer;
