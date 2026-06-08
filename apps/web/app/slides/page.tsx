import SlideShow from "./components/SlideShow";
import WhatIsMemeSOL from "./slides/WhatIsMemeSOL";

export const dynamic = "force-dynamic";

// 22 June 2026 4:00pm AEST (UTC+10)
const EVENT_DATE = new Date("2026-05-22T06:00:00Z");

export default function SlidesPage() {
  if (new Date() < EVENT_DATE) {
    return (
      <main className="min-h-screen bg-canvas text-ink flex items-center justify-center">
        <p className="text-ink/40">Slides available on 22 June.</p>
      </main>
    );
  }

  return <SlideShow slides={[<WhatIsMemeSOL key="what" />]} />;
}
