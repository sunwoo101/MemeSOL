import ScreenButton from "./ScreenButton";
import ScreenHeader from "./ScreenHeader";

export default function LaunchScreen() {
  return (
    <>
      <ScreenHeader title="Review" />
      <div className="flex-1 flex flex-col items-center gap-3">
        <div className="h-16 w-16 rounded-full bg-gradient-to-br from-accent to-info" />

        <div className="text-center">
          <p className="text-sm font-bold text-ink">MemeSOL</p>
          <p className="text-[10px] text-ink/40 mt-0.5">MSOL</p>
        </div>

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
