import { SiDotnet, SiReact, SiSwift } from "@icons-pack/react-simple-icons";
import { Globe, Mail, QrCode } from "lucide-react";
import Image from "next/image";
import React from "react";
import Slide from "../components/Slide";

const TECH = {
  ".NET": SiDotnet,
  Swift: SiSwift,
  React: SiReact,
} as const;

type TechName = keyof typeof TECH;

function TechChip({ name }: { name: TechName }) {
  const Icon = TECH[name];
  return (
    <span className="inline-flex items-center gap-1.5 rounded-full border border-ink/15 bg-ink/[0.03] px-2.5 py-1 text-xs text-ink/70">
      <Icon size={12} className="text-ink/50" />
      {name}
    </span>
  );
}

const TEAM: {
  name: string;
  initials: string;
  tech: TechName[];
  email: string;
  site?: string;
}[] = [
  {
    name: "Sun Woo Kim",
    initials: "SK",
    tech: [".NET", "Swift", "React"],
    email: "sun.kim101@outlook.com",
    site: "sunwookim.dev",
  },
  {
    name: "Daniel Liu",
    initials: "DL",
    tech: ["Swift", "React"],
    email: "DL56386994@gmail.com",
    site: "daniel-liu.dev",
  },
  {
    name: "Ineshka De Mel",
    initials: "ID",
    tech: ["Swift"],
    email: "VidanalageIneshkaRansini.DeMel@student.uts.edu.au",
  },
  {
    name: "Gurpreet Kaur",
    initials: "GK",
    tech: ["Swift"],
    email: "gurpreet.kaur-3@student.uts.edu.au",
  },
];

export default function Team() {
  return (
    <Slide>
      <div className="flex flex-col h-full gap-2">
        <h1 className="text-5xl font-bold tracking-tight text-ink">The Team</h1>
        <p className="text-ink/50 text-lg">
          Thanks for stopping by — we&apos;d love to hear from you.
        </p>

        {/* Three stacked grid rows (top / QR / contact) so the QR band is the
            same height across all cards regardless of contact-text length */}
        <div
          className="grid grid-cols-4 gap-x-3 flex-1 min-h-0 mt-4"
          style={{ gridTemplateRows: "auto 1fr auto", rowGap: 0 }}
        >
          {/* Row 1: avatar, name, tech */}
          {TEAM.map((member) => (
            <div
              key={member.name + "-top"}
              className="border-x border-t border-info/30 bg-info/10 rounded-t-xl px-5 pt-5 pb-3 flex flex-col gap-4"
            >
              <div className="flex items-center justify-center h-16 w-16 rounded-full bg-accent/20 border border-accent/40">
                <span className="text-xl font-bold text-ink">
                  {member.initials}
                </span>
              </div>

              <div className="flex flex-col gap-3">
                <p className="font-bold text-xl text-ink leading-tight">
                  {member.name}
                </p>
                <div className="flex flex-wrap gap-1.5">
                  {member.tech.map((t) => (
                    <TechChip key={t} name={t} />
                  ))}
                </div>
              </div>
            </div>
          ))}

          {/* Row 2: placeholder QR — links to the member's digital business card */}
          {TEAM.map((member) => (
            <div
              key={member.name + "-qr"}
              className="border-x border-info/30 bg-info/10 px-5 min-h-0 flex flex-col items-center gap-2 py-1"
            >
              <div className="flex-1 min-h-0 aspect-square">
                <QrCode size="100%" className="text-ink/70" />
              </div>
              <span className="inline-flex items-center gap-1 text-[10px] text-ink/40 shrink-0">
                Powered by
                <Image
                  src="/tiaga.svg"
                  alt="Tiaga"
                  width={12}
                  height={12}
                  className="rounded-[2px]"
                />
                <a
                  href="https://cards.tiaga.tech"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-[#00d985] hover:brightness-110 transition-all"
                >
                  cards.tiaga.tech
                </a>
              </span>
            </div>
          ))}

          {/* Row 3: contact */}
          {TEAM.map((member) => (
            <div
              key={member.name + "-contact"}
              className="border-x border-b border-info/30 bg-info/10 rounded-b-xl px-5 pt-3 pb-5 flex flex-col gap-2 text-sm"
            >
              <a
                href={`mailto:${member.email}`}
                className="flex items-start gap-2 text-ink/60 hover:text-ink transition-colors"
              >
                <Mail size={14} className="text-ink/40 shrink-0 mt-0.5" />
                <span className="break-all">{member.email}</span>
              </a>
              {member.site && (
                <a
                  href={`https://${member.site}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2 text-accent hover:brightness-110 transition-all"
                >
                  <Globe size={14} className="shrink-0" />
                  {member.site}
                </a>
              )}
            </div>
          ))}
        </div>
      </div>
    </Slide>
  );
}
