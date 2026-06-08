import { SiSwift } from "@icons-pack/react-simple-icons";
import { Image, KeyRound, QrCode, RefreshCw } from "lucide-react";
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

const CARDS = [
  {
    title: "Secure Token Storage",
    icon: KeyRound,
    lines: [
      "JWT and refresh token stored in iOS Keychain",
      "Wallet public key also stored in Keychain",
      "APIClient auto-refreshes JWT on 401, transparent to ViewModels",
      "RefreshCoordinator actor deduplicates concurrent refresh calls",
    ],
  },
  {
    title: "QR Code",
    icon: QrCode,
    lines: [
      "Generator — CoreImage CIFilter renders wallet address as QR",
      "Scanner — CodeScanner package reads QR on the send screen",
      ".interpolation(.none) keeps QR pixels crisp at any size",
      "Copy button with 1.5s 'Copied!' feedback",
    ],
  },
  {
    title: "Image Cache",
    icon: Image,
    lines: [
      "Two-tier: NSCache in memory (100 item limit)",
      "Overflow persisted to disk under Caches/TokenImages",
      "Disk hit promotes image back to memory cache",
      "Cache keyed by URL hash for fast lookup",
    ],
  },
  {
    title: "Artificial Refresh Delay",
    icon: RefreshCw,
    lines: [
      "Added so users always feel the app respond, even when data loads instantly",
      "Task.sleep enforces a 0.5s minimum via AppBehavior.artificialRefreshDuration",
      "Ensures the pull-to-refresh spinner is always visible long enough to register",
    ],
  },
];

export default function AppArchitecture() {
  return (
    <Slide>
      <div className="flex flex-col h-full gap-6">
        <h1 className="text-5xl font-bold tracking-tight text-ink">
          App Architecture
        </h1>

        {/* MVVM horizontal flow */}
        <div className="flex flex-col gap-3">
          <div className="flex items-center gap-2">
            <SiSwift size={14} className="text-ink/40" />
            <p className="text-xs font-semibold text-ink/40 uppercase tracking-wider">
              MVVM
            </p>
          </div>
          <div className="flex items-center gap-0">
            <Layer name="Views" detail="SwiftUI" />
            <LayerArrow />
            <Layer name="ViewModels" detail="@Observable" />
            <LayerArrow />
            <Layer
              name="Services"
              detail="APIClient · AuthSession · ImageCache"
            />
            <LayerArrow />
            <Layer name="Models" detail="Swift Codable structs" />
          </div>
        </div>

        {/* Two-row grid: text row is auto (sized to tallest card), icon row is 1fr
            so all four icons share the same height regardless of text wrapping */}
        <div
          className="grid grid-cols-4 gap-x-3 flex-1 min-h-0"
          style={{ gridTemplateRows: "auto 1fr", rowGap: 0 }}
        >
          {CARDS.map(({ title, lines }) => (
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
          {CARDS.map(({ title, icon: Icon }) => (
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
      </div>
    </Slide>
  );
}
