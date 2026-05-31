type Item = {
  title: string;
  description: string;
  accent: string;
  icon: string;
};

const items: Item[] = [
  {
    title: "Secure authentication",
    description:
      "Email and password registration with strong validation, persistent sessions via Keychain and auto-login on relaunch.",
    accent: "from-success to-info",
    icon: "✓",
  },
  {
    title: "Portfolio dashboard",
    description:
      "See your total balance with live gains and losses, plus quick buttons to Send, Receive and Buy.",
    accent: "from-warning to-accent",
    icon: "◎",
  },
  {
    title: "Token explorer",
    description:
      "Browse all available tokens, view detailed price, percent change, mint address and create your own token in seconds.",
    accent: "from-accent to-info",
    icon: "✦",
  },
  {
    title: "Send & receive",
    description:
      "Send tokens to any wallet address, generate a QR code to receive or scan a QR to auto fill the recipient.",
    accent: "from-info to-success",
    icon: "⇄",
  },
  {
    title: "Transaction history",
    description:
      "Full transaction history with clear status indicators, so you always know where every transfer stands.",
    accent: "from-accent to-warning",
    icon: "≡",
  },
  {
    title: "Native iOS feel",
    description:
      "Designed for iOS 17+ to feel fast, smooth, and right at home.",
    accent: "from-error to-warning",
    icon: "",
  },
];

function Feature() {
  return (
    <section id="features" className="relative py-28">
      <div className="max-w-6xl mx-auto px-6">
        <div className="max-w-2xl">
          <p className="text-sm font-semibold text-accent uppercase tracking-wider">
            Features
          </p>
          <h2 className="mt-3 text-4xl sm:text-5xl font-bold tracking-tight">
            Everything you need to manage your tokens.
          </h2>
        </div>

        <div className="mt-14 grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {items.map((item) => (
            <div
              key={item.title}
              className="group relative rounded-2xl border border-white/10 bg-white/[0.03] p-6 hover:bg-white/[0.06] hover:border-white/20 transition-all"
            >
              <div
                className={`h-11 w-11 rounded-xl bg-gradient-to-br ${item.accent} flex items-center justify-center text-lg font-bold`}
              >
                {item.icon}
              </div>
              <h3 className="mt-5 text-lg font-semibold">{item.title}</h3>
              <p className="mt-2 text-sm text-ink/65 leading-relaxed">
                {item.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export default Feature;
