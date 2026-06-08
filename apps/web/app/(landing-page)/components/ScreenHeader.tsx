export default function ScreenHeader({ title }: { title: string }) {
  return (
    <p className="text-xs font-semibold text-ink text-center mb-4">{title}</p>
  );
}
