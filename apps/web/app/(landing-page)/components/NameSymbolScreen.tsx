import ScreenButton from "./ScreenButton";
import ScreenHeader from "./ScreenHeader";
import ScreenInput from "./ScreenInput";

export default function NameSymbolScreen() {
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
