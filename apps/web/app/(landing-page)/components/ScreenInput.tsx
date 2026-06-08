export default function ScreenInput({
  label,
  placeholder,
  short,
}: {
  label: string;
  placeholder: string;
  short?: boolean;
}) {
  return (
    <div className={short ? "w-1/2" : "w-full"}>
      <p className="text-[9px] text-ink/40 uppercase tracking-wider mb-1">
        {label}
      </p>
      <div className="rounded-xl bg-ink/[0.06] border border-ink/[0.08] px-3 py-2 text-xs text-ink/30">
        {placeholder}
      </div>
    </div>
  );
}
