export default function ScreenButton({
  label,
  muted,
}: {
  label: string;
  muted?: boolean;
}) {
  return (
    <div
      className={`w-full rounded-xl py-2.5 flex items-center justify-center text-xs font-semibold ${muted ? "bg-ink/[0.06] text-ink/50" : "bg-accent text-ink"}`}
    >
      {label}
    </div>
  );
}
