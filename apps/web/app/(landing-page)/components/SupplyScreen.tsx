import ScreenButton from "./ScreenButton";
import ScreenHeader from "./ScreenHeader";
import ScreenInput from "./ScreenInput";

export default function SupplyScreen() {
  return (
    <>
      <ScreenHeader title="Token Supply" />
      <div className="flex flex-col gap-3 flex-1">
        <ScreenInput label="Total Supply" placeholder="e.g. 1,000,000,000" />
        <p className="text-[8px] text-ink/25 leading-relaxed">
          The total number of tokens that will ever exist. This cannot be
          changed after launch.
        </p>
      </div>
      <ScreenButton label="Next" />
    </>
  );
}
