import { SiNextdotjs } from "@icons-pack/react-simple-icons";
import { CalendarClock, Layout, Server } from "lucide-react";
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
    title: "Why Next.js",
    icon: SiNextdotjs,
    lines: [
      "Migrated from plain React to Next.js",
      "With React CSR, slide content lives in the JS bundle — visible to anyone before the event",
      "Next.js SSR lets the server decide what HTML to send",
      "Slide content never reaches the browser until the date check passes",
    ],
  },
  {
    title: "Slides Date Gate",
    icon: CalendarClock,
    lines: [
      "force-dynamic forces the page to re-render on every request",
      "Server checks the date before rendering any slide content",
      "Returns a placeholder page if the event hasn't started",
      "Slides are available from 22 June 4pm AEST",
    ],
  },
  {
    title: "Landing Page",
    icon: Layout,
    lines: [
      "Route group (landing-page) keeps the URL clean",
      "Sections: Hero, Feature, Festival countdown, Footer",
      "Festival countdown initialises in useEffect to avoid SSR hydration mismatch",
      "Statically generated for fast load times",
    ],
  },
  {
    title: "Deployment",
    icon: Server,
    lines: [
      "output: standalone bundles only the files needed to run",
      "Containerised with Docker alongside the backend",
      "Served on the same VPS behind the Caddy reverse proxy",
      "Caddy handles HTTPS and routes traffic to the correct container",
    ],
  },
];

export default function WebArchitecture() {
  return (
    <Slide>
      <div className="flex flex-col h-full gap-6">
        <h1 className="text-5xl font-bold tracking-tight text-ink">
          Web Architecture
        </h1>

        {/* Layer strip */}
        <div className="flex flex-col gap-2">
          <div className="flex items-center gap-2">
            <SiNextdotjs size={14} className="text-ink/40" />
            <p className="text-xs font-semibold text-ink/40 uppercase tracking-wider">
              Next.js App Router
            </p>
          </div>
          <div className="flex items-center gap-0">
            <Layer name="/" detail="Landing page" />
            <LayerArrow />
            <Layer name="/slides" detail="Date-gated slideshow" />
            <LayerArrow />
            <Layer name="Shared" detail="Components · Sections" />
          </div>
        </div>

        {/* Feature cards */}
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
