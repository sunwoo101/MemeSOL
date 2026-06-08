import { SiGithub } from "@icons-pack/react-simple-icons";
import { GitBranch, Rocket, TerminalSquare, UsersRound } from "lucide-react";
import React from "react";
import Slide from "../components/Slide";

function Step({ name }: { name: string }) {
  return (
    <div className="flex-1 rounded-xl border border-accent/40 bg-accent/15 px-3 py-2.5 text-center">
      <p className="font-semibold text-sm text-ink">{name}</p>
    </div>
  );
}

function StepArrow() {
  return (
    <div className="flex items-center w-5 shrink-0">
      <div className="h-px bg-ink/20 flex-1" />
      <span className="text-ink/20 text-xs leading-none">{"▶︎"}</span>
    </div>
  );
}

const CARDS = [
  {
    title: "Branching & PRs",
    icon: GitBranch,
    lines: [
      "Every feature, fix, and refactor lives on its own branch",
      "Nothing is committed straight to main",
      "PR titles follow Conventional Commits",
      "Format: type(scope): summary — e.g. feat(backend): create token endpoint",
    ],
  },
  {
    title: "Code Review",
    icon: UsersRound,
    lines: [
      "Every PR needs at least 2 approving reviews before merge",
      "CodeRabbit adds an automated AI review pass on every PR",
      "Branch protection blocks merging without approvals",
      "Catches bugs early and spreads codebase knowledge",
    ],
  },
  {
    title: "CI/CD",
    icon: Rocket,
    lines: [
      "GitHub Actions builds and deploys on every merge to main",
      "Path filters skip deploys when only unrelated files change",
      "Builds the backend, then deploys over SSH to the VPS",
      "Manual deploys are possible but slower — the pipeline is the default",
    ],
  },
  {
    title: "VPS Control via Claude Code",
    icon: TerminalSquare,
    lines: [
      "Claude Code runs in a tmux session on the VPS with /remote-control",
      "The VPS can be driven from the Claude Code web or mobile app",
      "Make changes from anywhere — no SSH session to babysit",
      "No need to memorise and run commands by hand over SSH",
    ],
  },
];

export default function DeveloperWorkflow() {
  return (
    <Slide>
      <div className="flex flex-col h-full gap-6">
        <h1 className="text-5xl font-bold tracking-tight text-ink">
          Developer Workflow
        </h1>

        {/* Workflow step strip */}
        <div className="flex flex-col gap-2">
          <div className="flex items-center gap-2">
            <SiGithub size={14} className="text-ink/40" />
            <p className="text-xs font-semibold text-ink/40 uppercase tracking-wider">
              GitHub
            </p>
          </div>
          <div className="flex items-center gap-0">
            <Step name="Branch" />
            <StepArrow />
            <Step name="Open PR" />
            <StepArrow />
            <Step name="2 Reviews" />
            <StepArrow />
            <Step name="Merge to main" />
            <StepArrow />
            <Step name="Auto Deploy" />
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
