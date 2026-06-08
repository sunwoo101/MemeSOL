import type { ReactNode } from "react";

type FeatureProps = {
  title: string;
  description: string;
  step?: number;
  reverse?: boolean;
  screen?: ReactNode;
};

function IPhoneMockup({ children }: { children?: ReactNode }) {
  return (
    <div className="relative mx-auto w-[260px] aspect-[9/19.5] rounded-[3rem] border-[10px] border-ink/20 bg-canvas shadow-2xl shadow-canvas overflow-hidden">
      {/* Notch */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-20 h-5 bg-ink/20 rounded-b-2xl z-10" />
      {/* Volume buttons */}
      <div className="absolute -left-[14px] top-20 w-[4px] h-8 rounded-l-full bg-ink/20" />
      <div className="absolute -left-[14px] top-32 w-[4px] h-12 rounded-l-full bg-ink/20" />
      <div className="absolute -left-[14px] top-48 w-[4px] h-12 rounded-l-full bg-ink/20" />
      {/* Power button */}
      <div className="absolute -right-[14px] top-28 w-[4px] h-16 rounded-r-full bg-ink/20" />
      {/* Screen content */}
      <div className="absolute inset-0 pt-7 px-4 pb-5 flex flex-col">
        {children}
      </div>
    </div>
  );
}

function Feature({
  title,
  description,
  step,
  reverse = false,
  screen,
}: FeatureProps) {
  return (
    <section className="relative py-24 border-t border-ink/5">
      <div className="max-w-6xl mx-auto px-6">
        <div
          className={`flex flex-col ${reverse ? "md:flex-row-reverse" : "md:flex-row"} items-center gap-16`}
        >
          {/* Text */}
          <div className="flex-1 max-w-lg">
            {step !== undefined && (
              <p className="text-sm font-semibold text-accent uppercase tracking-wider mb-3">
                Step {step}
              </p>
            )}
            <h2 className="text-3xl sm:text-4xl font-bold tracking-tight leading-tight">
              {title}
            </h2>
            <p className="mt-5 text-base text-ink/60 leading-relaxed">
              {description}
            </p>
          </div>

          {/* iPhone mockup */}
          <div className="flex-1 flex justify-center">
            <IPhoneMockup>{screen}</IPhoneMockup>
          </div>
        </div>
      </div>
    </section>
  );
}

export default Feature;
