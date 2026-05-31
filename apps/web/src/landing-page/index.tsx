import Navbar from "../common/components/Navbar";
import Feature from "../common/sections/Feature";
import Footer from "../common/sections/Footer";
import Hero from "./sections/Hero";

// Landing page: stacks the top bar, main content and footer.
function Home() {
  return (
    <div className="min-h-screen bg-canvas text-ink">
      <Navbar /> {/* Sticky top navigation */}
      <main>
        <Hero /> {/* Headline and download button */}
        <Feature /> {/* Feature cards shown after scrolling */}
      </main>
      <Footer /> {/* Download CTA and site links */}
    </div>
  );
}

export default Home;
