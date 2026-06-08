"use client";

import { useEffect, useState } from "react";

// 22 June 2026 4:00pm AEST (UTC+10)
const EVENT = new Date("2026-06-22T06:00:00Z");
// 22 June 2026 7:30pm AEST (UTC+10)
const EVENT_END = new Date("2026-06-22T09:30:00Z");

function getTimeLeft() {
  const diff = EVENT.getTime() - Date.now();
  if (diff <= 0) return null;
  return {
    days: Math.floor(diff / 864e5),
    hours: Math.floor((diff % 864e5) / 36e5),
    minutes: Math.floor((diff % 36e5) / 6e4),
    seconds: Math.floor((diff % 6e4) / 1e3),
  };
}

function Pad({ value, label }: { value: number; label: string }) {
  return (
    <div className="flex flex-col items-center gap-2">
      <span className="text-4xl sm:text-5xl font-bold tracking-tight tabular-nums">
        {String(value).padStart(2, "0")}
      </span>
      <span className="text-[10px] text-ink/40 uppercase tracking-widest">{label}</span>
    </div>
  );
}

function Festival() {
  const [timeLeft, setTimeLeft] = useState(getTimeLeft);

  useEffect(() => {
    const id = setInterval(() => setTimeLeft(getTimeLeft()), 1000);
    return () => clearInterval(id);
  }, []);

  const isOver = Date.now() >= EVENT_END.getTime();

  if (isOver) return null;

  return (
    <section id="steps" className="border-t border-ink/5 py-16">
      <div className="max-w-6xl mx-auto px-6 flex flex-col items-center text-center gap-6">
        <p className="text-sm font-semibold text-accent uppercase tracking-wider">
          UTS Tech Festival
        </p>

        {timeLeft ? (
          <>
            <div className="flex items-start gap-8 sm:gap-12">
              <Pad value={timeLeft.days} label="Days" />
              <Pad value={timeLeft.hours} label="Hours" />
              <Pad value={timeLeft.minutes} label="Minutes" />
              <Pad value={timeLeft.seconds} label="Seconds" />
            </div>
            <p className="text-ink/50 text-sm">
              Come see the MemeSOL beta at{" "}
              <span className="text-ink">Building 11, Level 4</span> — 22 June,{" "}
              <span className="text-ink">4pm to 7:30pm</span>
            </p>
            <a
              href="https://events.humanitix.com/software-engineering-showcase-uts-tech-festival-2026"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 rounded-full bg-accent text-ink px-5 py-2 text-sm font-semibold hover:brightness-110 transition-all"
            >
              Get Tickets
            </a>
          </>
        ) : (
          <>
            <h2 className="text-4xl sm:text-5xl font-bold tracking-tight">
              We're here today.
            </h2>
            <p className="text-ink/60 text-base">
              Come see the MemeSOL beta at{" "}
              <span className="text-ink">Building 11, Level 4</span> — today,{" "}
              <span className="text-ink">4pm to 7:30pm</span>.
            </p>
          </>
        )}
      </div>
    </section>
  );
}

export default Festival;
