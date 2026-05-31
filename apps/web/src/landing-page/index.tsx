import Navbar from "../common/components/Navbar";
import Feature from "../common/sections/Feature";
import Footer from "../common/sections/Footer";
import Hero from "./sections/Hero";

function Home() {
  return (
    <div className="min-h-screen bg-canvas text-ink">
      <Navbar />
      <main>
        <Hero />
        <Feature />
      </main>
      <Footer />
    </div>
  );
}

export default Home;
