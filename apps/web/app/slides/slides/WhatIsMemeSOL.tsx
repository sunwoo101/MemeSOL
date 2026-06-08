import Slide from "../components/Slide";
import Image from "next/image";

export default function WhatIsMemeSOL() {
  return (
    <Slide>
      <div className="flex h-full gap-16 items-center">
        {/* Left: logo */}
        <div className="flex-1 flex items-center justify-center">
          <Image src="/favicon.svg" alt="MemeSOL" width={0} height={0} className="w-full h-auto p-12" />
        </div>

        {/* Right: content */}
        <div className="flex-1 flex flex-col gap-8 min-w-0">
          <h1 className="text-5xl font-bold tracking-tight text-ink">MemeSOL</h1>

          <p className="text-2xl text-ink/60 leading-snug">
            An iOS app that lets anyone create and launch a meme coin on{" "}
            <span className="text-ink">Solana</span> in seconds, no coding required.
          </p>

          <ul className="flex flex-col gap-4 text-lg text-ink/70">
            <li className="flex items-start gap-3">
              <span className="text-accent mt-1">→</span>
              Pick a name, symbol and image and the app handles everything else
            </li>
            <li className="flex items-start gap-3">
              <span className="text-accent mt-1">→</span>
              Token is deployed live to Solana mainnet instantly (currently devnet for testing)
            </li>
            <li className="flex items-start gap-3">
              <span className="text-accent mt-1">→</span>
              Built with Swift (iOS), .NET backend, and a Next.js landing page
            </li>
          </ul>
        </div>
      </div>
    </Slide>
  );
}
