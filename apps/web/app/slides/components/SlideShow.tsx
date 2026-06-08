"use client";

import { useState } from "react";

export default function SlideShow({ slides }: { slides: React.ReactNode[] }) {
  const [index, setIndex] = useState(0);
  const total = slides.length;

  return (
    <div className="bg-canvas flex items-center justify-center w-screen h-screen p-4">
      <div
        className="bg-canvas flex flex-col gap-4 items-center justify-center w-full h-full"
      >
        {/* Slide */}
        <div className="bg-canvas border border-ink/10 rounded-2xl overflow-hidden shadow-lg shadow-ink/10 w-full h-full">
          {slides[index]}
        </div>

        {/* Navigation */}
        <div className="flex items-center justify-between gap-8">
          <button
            onClick={() => setIndex((i) => i - 1)}
            disabled={index === 0}
            className="flex items-center justify-center w-11 h-11 rounded-full border border-ink/10 text-ink/60 hover:text-ink hover:border-ink/30 disabled:opacity-20 disabled:cursor-not-allowed transition-all"
          >
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
          </button>

          <span className="text-sm text-ink/40 tabular-nums">{index + 1} / {total}</span>

          <button
            onClick={() => setIndex((i) => i + 1)}
            disabled={index === total - 1}
            className="flex items-center justify-center w-11 h-11 rounded-full border border-ink/10 text-ink/60 hover:text-ink hover:border-ink/30 disabled:opacity-20 disabled:cursor-not-allowed transition-all"
          >
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </button>
        </div>
      </div>
    </div>
  );
}
