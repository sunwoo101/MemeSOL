export default function Slide({
  children,
}: {
  title?: string;
  children?: React.ReactNode;
}) {
  return <div className="w-full h-full p-12">{children}</div>;
}
