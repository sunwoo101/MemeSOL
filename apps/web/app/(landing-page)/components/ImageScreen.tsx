import ScreenButton from "./ScreenButton";
import ScreenHeader from "./ScreenHeader";

export default function ImageScreen() {
  return (
    <>
      <ScreenHeader title="Token Image" />
      <div className="flex-1 flex flex-col gap-3">
        <div className="w-full aspect-square rounded-2xl border border-dashed border-ink/20 flex flex-col items-center justify-center gap-2">
          <div className="h-8 w-8 rounded-full bg-ink/[0.06] flex items-center justify-center">
            <svg
              className="h-4 w-4 text-ink/30"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              strokeWidth={1.5}
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5"
              />
            </svg>
          </div>
          <p className="text-[9px] text-ink/30">Tap to upload</p>
        </div>

        <div className="flex items-center justify-between rounded-xl bg-ink/[0.06] border border-ink/[0.08] px-3 py-2">
          <div>
            <p className="text-[10px] font-medium text-ink/80">
              I&apos;m feeling lucky
            </p>
            <p className="text-[8px] text-ink/35">AI generate an image</p>
          </div>
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
