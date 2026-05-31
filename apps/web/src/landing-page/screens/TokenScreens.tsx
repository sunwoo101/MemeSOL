function ScreenHeader({ title }: { title: string }) {
  return (
    <p className="text-xs font-semibold text-ink text-center mb-4">{title}</p>
  );
}

function ScreenInput({ label, placeholder, short }: { label: string; placeholder: string; short?: boolean }) {
  return (
    <div className={short ? "w-1/2" : "w-full"}>
      <p className="text-[9px] text-ink/40 uppercase tracking-wider mb-1">{label}</p>
      <div className="rounded-xl bg-ink/[0.06] border border-ink/[0.08] px-3 py-2 text-xs text-ink/30">
        {placeholder}
      </div>
    </div>
  );
}

function ScreenButton({ label, muted }: { label: string; muted?: boolean }) {
  return (
    <div className={`w-full rounded-xl py-2.5 flex items-center justify-center text-xs font-semibold ${muted ? "bg-ink/[0.06] text-ink/50" : "bg-accent text-ink"}`}>
      {label}
    </div>
  );
}

export function NameSymbolScreen() {
  return (
    <>
      <ScreenHeader title="New Token" />
      <div className="flex flex-col gap-3 flex-1">
        <ScreenInput label="Token Name" placeholder="e.g. MemeSOL" />
        <ScreenInput label="Token Symbol" placeholder="e.g. MSOL" />
        <ScreenInput label="Total Supply" placeholder="e.g. 1,000,000,000" />
      </div>
      <ScreenButton label="Next" />
    </>
  );
}

export function ImageScreen() {
  return (
    <>
      <ScreenHeader title="Token Image" />
      <div className="flex-1 flex flex-col gap-3">
        {/* Upload area */}
        <div className="w-full aspect-square rounded-2xl border border-dashed border-ink/20 flex flex-col items-center justify-center gap-2">
          <div className="h-8 w-8 rounded-full bg-ink/[0.06] flex items-center justify-center">
            <svg className="h-4 w-4 text-ink/30" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5" />
            </svg>
          </div>
          <p className="text-[9px] text-ink/30">Tap to upload</p>
        </div>

        {/* I'm feeling lucky toggle */}
        <div className="flex items-center justify-between rounded-xl bg-ink/[0.06] border border-ink/[0.08] px-3 py-2">
          <div>
            <p className="text-[10px] font-medium text-ink/80">I'm feeling lucky</p>
            <p className="text-[8px] text-ink/35">AI generate an image</p>
          </div>
          {/* Toggle (on state) */}
          <div className="w-8 h-4 rounded-full bg-accent flex items-center justify-end pr-0.5">
            <div className="w-3 h-3 rounded-full bg-ink" />
          </div>
        </div>
      </div>

      <div className="mt-3">
        <ScreenButton label="Next" />
      </div>
    </>
  );
}

export function SupplyScreen() {
  return (
    <>
      <ScreenHeader title="Token Supply" />
      <div className="flex flex-col gap-3 flex-1">
        <ScreenInput label="Total Supply" placeholder="e.g. 1,000,000,000" />
        <p className="text-[8px] text-ink/25 leading-relaxed">
          The total number of tokens that will ever exist. This cannot be changed after launch.
        </p>
      </div>
      <ScreenButton label="Next" />
    </>
  );
}

export function LaunchScreen() {
  return (
    <>
      <ScreenHeader title="Review" />
      <div className="flex-1 flex flex-col items-center gap-3">
        {/* Token image placeholder */}
        <div className="h-16 w-16 rounded-full bg-gradient-to-br from-accent to-info" />

        {/* Token details */}
        <div className="text-center">
          <p className="text-sm font-bold text-ink">MemeSOL</p>
          <p className="text-[10px] text-ink/40 mt-0.5">MSOL</p>
        </div>

        {/* Detail rows */}
        <div className="w-full rounded-xl bg-ink/[0.06] border border-ink/[0.08]">
          <div className="flex justify-between items-center px-3 py-2">
            <p className="text-[9px] text-ink/40">Supply</p>
            <p className="text-[9px] font-medium text-ink">1,000,000,000</p>
          </div>
        </div>
      </div>

      <div className="mt-3">
        <ScreenButton label="Launch" />
      </div>
    </>
  );
}
