import { SiDotnet } from "@icons-pack/react-simple-icons";
import {
  AlertCircle,
  ShieldCheck,
  Sparkles,
  TrendingUp,
  Wallet,
  Zap,
} from "lucide-react";
import React from "react";
import Slide from "../components/Slide";

function Layer({ name, detail }: { name: string; detail: string }) {
  return (
    <div className="flex-1 rounded-xl border border-accent/40 bg-accent/15 px-4 py-3">
      <p className="font-bold text-xl text-ink">{name}</p>
      <p className="text-sm text-ink/40 font-mono mt-0.5">{detail}</p>
    </div>
  );
}

function LayerArrow() {
  return (
    <div className="flex items-center w-6 shrink-0">
      <div className="h-px bg-ink/20 flex-1" />
      <span className="text-ink/20 text-xs leading-none">{"▶︎"}</span>
    </div>
  );
}

const ROW_ONE = [
  {
    title: "Auth & Security",
    icon: ShieldCheck,
    lines: [
      "Passwords hashed with PBKDF2 via ASP.NET Identity PasswordHasher",
      "Refresh tokens stored as SHA-256 hash — raw token never persisted",
      "Token rotated on every refresh call",
      "JWT signed with HMAC-SHA256, expires after 60 minutes",
    ],
  },
  {
    title: "Token Creation",
    icon: Sparkles,
    lines: [
      "Saves a Pending record before the on-chain call for failure recovery",
      "Failed on-chain call marks token as Failed — no orphaned DB records",
      '"I\'m Feeling Lucky" uses Google Imagen 4.0 to generate a meme coin logo',
      "Name and symbol uniqueness enforced before creation",
    ],
  },
  {
    title: "Transaction Cache",
    icon: Zap,
    lines: [
      "IMemoryCache caches Solana transaction history per wallet + mint",
      "5-minute TTL to balance freshness and Solana RPC load",
      "Cache explicitly invalidated on send or buy",
      "AllTransactions fetches all tokens in parallel with Task.WhenAll",
    ],
  },
];

const ROW_TWO = [
  {
    title: "Price Simulation",
    icon: TrendingUp,
    lines: [
      "Random walk ±5% per hour per token",
      "Daily open price resets at midnight for gain/loss calculation",
      "Simulated only — not suitable for launch as-is",
      "Needs a proper pricing model based on supply and demand",
    ],
  },
  {
    title: "Error Handling",
    icon: AlertCircle,
    lines: [
      "GlobalExceptionHandler maps exception types to HTTP status codes",
      "InvalidOperationException → 400, UnauthorizedAccessException → 401",
      "KeyNotFoundException → 404, all others → 500",
      "Consistent JSON error response format across all endpoints",
    ],
  },
  {
    title: "Auto-wallet on Send",
    icon: Wallet,
    lines: [
      "If recipient is a registered user, token is auto-added to their wallet",
      "UserToken record created with duplicate protection (PostgreSQL 23505)",
      "Transaction cache invalidated for both sender and recipient",
      "Sender and recipient balances update immediately on Solana",
    ],
  },
];

function CardGrid({
  cards,
}: {
  cards: {
    title: string;
    icon: React.ComponentType<{ size: string; className?: string }>;
    lines: string[];
  }[];
}) {
  return (
    <div
      className="grid grid-cols-3 gap-x-3 flex-1 min-h-0"
      style={{ gridTemplateRows: "auto 1fr", rowGap: 0 }}
    >
      {cards.map(({ title, lines }) => (
        <div
          key={title}
          className="border border-b-0 border-info/30 bg-info/10 rounded-t-xl p-4 flex flex-col gap-3"
        >
          <p className="font-bold text-2xl text-ink">{title}</p>
          <ul className="flex flex-col gap-2.5">
            {lines.map((l) => (
              <li
                key={l}
                className="flex items-start gap-2 text-sm text-ink/60"
              >
                <span className="text-accent/70 shrink-0 mt-0.5">→</span>
                {l}
              </li>
            ))}
          </ul>
        </div>
      ))}
      {cards.map(({ title, icon: Icon }) => (
        <div
          key={title + "-icon"}
          className="border border-t-0 border-info/30 bg-info/10 rounded-b-xl px-4 pb-4 relative overflow-hidden"
        >
          <div className="absolute bottom-0 right-0 h-full aspect-square">
            <Icon size="100%" className="text-ink/5" />
          </div>
        </div>
      ))}
    </div>
  );
}

export default function BackendArchitecture() {
  return (
    <Slide>
      <div className="flex flex-col h-full gap-4">
        <h1 className="text-5xl font-bold tracking-tight text-ink">
          Backend Architecture
        </h1>

        {/* Layer strip */}
        <div className="flex flex-col gap-2">
          <div className="flex items-center gap-2">
            <SiDotnet size={14} className="text-ink/40" />
            <p className="text-xs font-semibold text-ink/40 uppercase tracking-wider">
              ASP.NET Core
            </p>
          </div>
          <div className="flex items-center gap-0">
            <Layer name="Controllers" detail="Auth · Tokens · Wallet" />
            <LayerArrow />
            <Layer name="Services" detail="Auth · Tokens · Wallet · Solana" />
            <LayerArrow />
            <Layer name="Data" detail="EF Core · AppDbContext" />
          </div>
        </div>

        {/* Feature cards — two rows of three */}
        <div className="flex flex-col gap-3 flex-1 min-h-0">
          <CardGrid cards={ROW_ONE} />
          <CardGrid cards={ROW_TWO} />
        </div>
      </div>
    </Slide>
  );
}
