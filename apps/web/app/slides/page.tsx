import SlideShow from "./components/SlideShow";
import AppArchitecture from "./slides/AppArchitecture";
import BackendArchitecture from "./slides/BackendArchitecture";
import DeveloperWorkflow from "./slides/DeveloperWorkflow";
import SystemArchitecture from "./slides/SystemArchitecture";
import Team from "./slides/Team";
import WebArchitecture from "./slides/WebArchitecture";
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

  return (
    <SlideShow
      slides={[
        <WhatIsMemeSOL key="1" />,
        <SystemArchitecture key="2" />,
        <AppArchitecture key="3" />,
        <BackendArchitecture key="4" />,
        <WebArchitecture key="5" />,
        <DeveloperWorkflow key="6" />,
        <Team key="7" />,
      ]}
    />
  );
}
