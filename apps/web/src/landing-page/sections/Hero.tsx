import Button from "../../common/components/Button";

// Hero: fills the first screen with the headline and download button.
function Hero() {
  return (
    // Full viewport height (minus the navbar) so only the hero shows on load.
    <section className="relative overflow-hidden min-h-[calc(100vh-4rem)] flex items-center">
      {/* Faint grid pattern in the background */}
      <div className="absolute inset-0 -z-10">
        <div
          className="absolute inset-0 opacity-[0.04]"
          style={{
            backgroundImage:
              "linear-gradient(var(--color-ink) 1px, transparent 1px), linear-gradient(90deg, var(--color-ink) 1px, transparent 1px)",
            backgroundSize: "48px 48px",
          }}
        />
      </div>

      {/* Centered content column */}
      <div className="max-w-3xl mx-auto px-6 py-20 text-center">
        {/* Small "Now in beta" pill with a pulsing dot */}
        <div className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs text-ink/70 backdrop-blur">
          <span className="h-1.5 w-1.5 rounded-full bg-success animate-pulse" />
          Now in beta
        </div>

        {/* Main headline (last part uses a purple gradient) */}
        <h1 className="mt-3 text-5xl sm:text-6xl lg:text-7xl font-bold tracking-tight leading-[1.05]">
          The smarter way for {" "}
          <span className="bg-gradient-to-r from-accent via-info to-accent bg-clip-text text-transparent">
            sending, tracking and owning crypto
          </span>
        </h1>

        {/* Primary call to action button */}
        <div className="mt-14 flex justify-center">
          <Button size="lg" className="h-16 px-12 text-lg">
            Download MemeSOL
          </Button>
        </div>
      </div>
    </section>
  );
}

export default Hero;
