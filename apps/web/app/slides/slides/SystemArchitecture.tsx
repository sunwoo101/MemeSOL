import React from "react";
import {
  SiSwift,
  SiDotnet,
  SiPostgresql,
  SiSolana,
  SiNextdotjs,
  SiDocker,
} from "@icons-pack/react-simple-icons";
import Slide from "../components/Slide";

function Node({
  name,
  tech,
  details,
  icon: Icon,
  accent = false,
}: {
  name: string;
  tech: string;
  details: string[];
  icon: React.ComponentType<{ size: number; className?: string }>;
  accent?: boolean;
}) {
  return (
    <div
      className={`h-full rounded-2xl border p-5 flex flex-col gap-3 ${
        accent ? "border-accent/40 bg-accent/15" : "border-info/30 bg-info/10"
      }`}
    >
      <div className="flex items-center gap-3">
        <Icon size={28} className="text-ink/40" />
        <div>
          <p className="font-bold text-xl text-ink">
            {name}
          </p>
          <p className="text-sm text-ink/40 font-mono mt-0.5">{tech}</p>
        </div>
      </div>
      <ul className="flex flex-col gap-1.5">
        {details.map((d) => (
          <li key={d} className="flex items-start gap-2 text-sm text-ink/60">
            <span className="text-accent/70 shrink-0 mt-0.5">→</span>
            {d}
          </li>
        ))}
      </ul>
    </div>
  );
}

function HArrow({ label }: { label: string }) {
  return (
    <div className="flex flex-col items-center gap-1.5">
      <span className="text-[11px] text-ink/35 text-center leading-tight">
        {label}
      </span>
      <div className="flex items-center w-full">
        <div className="h-px bg-ink/20 flex-1" />
        <span className="text-ink/20 text-xs leading-none">{"▶︎"}</span>
      </div>
    </div>
  );
}

function VArrow({ label }: { label: string }) {
  return (
    <div className="flex justify-center items-center gap-2">
      <div className="flex flex-col items-center">
        <div className="w-px h-24 bg-ink/20" />
        <span className="text-ink/20 text-xs leading-none">{"▼"}</span>
      </div>
      <span className="text-[11px] text-ink/35">{label}</span>
    </div>
  );
}

export default function SystemArchitecture() {
  return (
    <Slide>
      <div className="flex flex-col h-full gap-6">
        <h1 className="text-5xl font-bold tracking-tight text-ink">
          System Architecture
        </h1>

        {/* grid: ios | h-arrow | backend | h-arrow | solana */}
        <div className="grid grid-cols-[1fr_6rem_1fr_6rem_1fr] content-start flex-1">
          {/* Row 1: main nodes — iOS and Solana self-center against the backend card */}
          <div>
            <Node
              name="iOS App"
              tech="Swift / SwiftUI"
              icon={SiSwift}
              details={[
                "Email & password auth",
                "Create coins with name, symbol & image",
                "Send & receive tokens",
              ]}
            />
          </div>

          <div className="self-center">
            <HArrow label="REST API" />
          </div>

          <Node
            name=".NET Backend"
            tech="ASP.NET Core · Docker"
            icon={SiDotnet}
            accent
            details={[
              "Auth — issues JWT & refresh tokens",
              "Manages server-side wallets",
              "Creates & mints SPL tokens",
              "Handles token transfers",
            ]}
          />

          <div className="self-center">
            <HArrow label="Solnet RPC" />
          </div>

          <div>
            <Node
              name="Solana"
              tech="SPL Token Program"
              icon={SiSolana}
              details={[
                "Token mint created on-chain",
                "Tokens minted to user ATAs",
                "Devnet (mainnet-ready)",
              ]}
            />
          </div>

          {/* Row 2: vertical arrow under backend only */}
          <div />
          <div />
          <VArrow label="SQL" />
          <div />
          <div />

          {/* Row 3: postgres under backend only */}
          <div />
          <div />
          <Node
            name="SQL Database"
            tech="PostgreSQL · Docker"
            icon={SiPostgresql}
            details={["Users & auth", "Token metadata", "User saved tokens"]}
          />
          <div />
          <div />
        </div>

        {/* Footer */}
        <div className="flex gap-3">
          <div className="flex-1 rounded-xl border border-warning/30 bg-warning/10 px-5 py-3 flex items-center gap-3">
            <SiNextdotjs size={18} className="text-ink/40 shrink-0" />
            <p className="font-semibold text-sm text-ink">Next.js</p>
            <div className="h-3.5 w-px bg-ink/15" />
            <p className="text-sm text-ink/40">
              Landing page — separate from the coin flow
            </p>
          </div>
          <div className="flex-1 rounded-xl border border-warning/30 bg-warning/10 px-5 py-3 flex items-center gap-3">
            <SiDocker size={18} className="text-ink/40 shrink-0" />
            <p className="font-semibold text-sm text-ink">Infrastructure</p>
            <div className="h-3.5 w-px bg-ink/15" />
            <p className="text-sm text-ink/40">
              Backend + DB containerised with Docker on a VPS, behind a Caddy
              reverse proxy
            </p>
          </div>
        </div>
      </div>
    </Slide>
  );
}
