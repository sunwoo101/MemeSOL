export default function Slide({
  title,
  children,
}: {
  title?: string;
  children?: React.ReactNode;
}) {
  return (
    <div className="flex flex-col h-full p-14">
      {title && (
        <h2 className="text-4xl font-bold tracking-tight text-ink mb-10">
          {title}
        </h2>
      )}
      <div className="flex-1 text-ink/80 text-lg leading-relaxed">
        {children}
      </div>
    </div>
  );
}
