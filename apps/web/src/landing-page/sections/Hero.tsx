import Button from "../../common/components/Button";

function Hero() {
  return (
    <section className="relative min-h-screen flex items-center overflow-hidden">
      {/* Background glows */}
      <div className="absolute inset-0 -z-10 pointer-events-none">
        <div className="absolute top-1/2 right-[-10%] -translate-y-1/2 w-[700px] h-[700px] bg-accent/20 rounded-full blur-[130px]" />
        <div className="absolute top-1/3 right-1/3 w-[350px] h-[350px] bg-info/10 rounded-full blur-[100px]" />
      </div>

      <div className="max-w-6xl mx-auto px-6 w-full grid md:grid-cols-2 gap-12 items-center py-24">
        {/* Left: headline and CTAs */}
        <div>
          {/* Headline */}
          <h1 className="text-6xl sm:text-7xl lg:text-[5.5rem] font-bold tracking-tight leading-[0.95]">
            Launch a<br />
            <span className="bg-gradient-to-r from-accent via-info to-accent bg-clip-text text-transparent">
              meme coin
            </span>
            <br />
            in one tap.
          </h1>

          <p className="mt-8 text-base text-ink/55 max-w-sm leading-relaxed">
            MemeSOL lets you create, launch, and trade meme coins
            straight from your iPhone. No coding required.
          </p>

          {/* CTAs */}
          <div className="mt-10">
            <a href="#steps">
              <Button size="lg">How it works</Button>
            </a>
          </div>
        </div>

        {/* Right: iPhone mockup with glow */}
        <div className="hidden md:flex justify-center items-center relative">
          <div className="absolute w-[340px] h-[340px] bg-accent/25 rounded-full blur-[90px]" />
          <div className="relative w-[300px] aspect-[9/19.5] rounded-[3.5rem] border-[12px] border-ink/20 bg-canvas shadow-2xl shadow-canvas overflow-hidden">
            {/* Notch */}
            <div className="absolute top-0 left-1/2 -translate-x-1/2 w-24 h-6 bg-ink/20 rounded-b-2xl z-10" />
            {/* Volume buttons */}
            <div className="absolute -left-[16px] top-20 w-[4px] h-8 rounded-l-full bg-ink/20" />
            <div className="absolute -left-[16px] top-32 w-[4px] h-12 rounded-l-full bg-ink/20" />
            <div className="absolute -left-[16px] top-48 w-[4px] h-12 rounded-l-full bg-ink/20" />
            {/* Power button */}
            <div className="absolute -right-[16px] top-28 w-[4px] h-16 rounded-r-full bg-ink/20" />

            {/* Screen content */}
            <div className="flex flex-col items-center justify-center px-5 h-full">
              {/* Logo circle */}
              <img src="/logo-circle.svg" alt="MemeSOL" className="h-16 w-16 rounded-full" />
              <p className="mt-2 text-sm font-semibold text-ink tracking-tight">MemeSOL</p>

              {/* Balance card */}
              <div className="mt-6 w-full rounded-2xl bg-ink/[0.07] border border-ink/10 px-4 py-4 flex flex-col items-center">
                <p className="text-[10px] text-ink/40 uppercase tracking-widest">Your Balance</p>
                <div className="mt-1 flex items-baseline gap-1.5">
                  <p className="text-2xl font-bold tracking-tight text-ink">1,000,000</p>
                  <p className="text-2xl font-bold tracking-tight text-ink">MSOL</p>
                </div>
              </div>

              {/* Add to wallet button */}
              <button className="mt-4 w-full rounded-2xl bg-accent text-ink text-sm font-semibold py-3 transition-colors">
                Add to Wallet
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export default Hero;
