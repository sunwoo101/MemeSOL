function Footer() {
  return (
    <footer className="relative border-t border-ink/5">
      <div className="max-w-6xl mx-auto px-6 pt-12 pb-12">
        {/* Brand blurb and link columns */}
        <div className="grid md:grid-cols-[1.5fr_repeat(3,1fr)] gap-10">
          {/* Brand: logo, name and tagline */}
          <div>
            <div className="flex items-center gap-2">
              <img src="/favicon.svg" alt="MemeSOL" className="h-7 w-7" />
              <span className="font-bold tracking-tight">MemeSOL</span>
            </div>
            <p className="mt-4 text-sm text-ink/60 max-w-xs">
              Launch your meme coin in seconds.
            </p>
          </div>

        </div>

        {/* Bottom bar: copyright and legal links */}
        <div className="mt-12 pt-8 border-t border-ink/5 flex flex-col sm:flex-row justify-between items-center gap-4 text-xs text-ink/50">
          <p>© {new Date().getFullYear()} MemeSOL, All Rights Reserved.</p>
        </div>
      </div>
    </footer>
  );
}

export default Footer;
