import Feature from "../common/sections/Feature";
import Festival from "../common/sections/Festival";
import Footer from "../common/sections/Footer";
import Hero from "./sections/Hero";
import {
  ImageScreen,
  LaunchScreen,
  NameSymbolScreen,
} from "./screens/TokenScreens";

function Home() {
  return (
    <div className="min-h-screen bg-canvas text-ink">
      <main>
        <Hero />
        <div id="how-to-launch">
          <Feature
            step={1}
            title="Pick a name and symbol."
            description="Give your token a name and a ticker symbol. These are the two things your community will recognise it by."
            screen={<NameSymbolScreen />}
          />
          <Feature
            step={2}
            title="Upload an image or generate one."
            description="Upload your own token image, or toggle 'I'm feeling lucky' and let the app generate one for you."
            reverse
            screen={<ImageScreen />}
          />
          <Feature
            step={3}
            title="Hit launch. You're live."
            description="One tap and your meme coin is deployed to Solana. Your community can find it instantly by searching for it in the app."
            screen={<LaunchScreen />}
          />
        </div>
      </main>
      <Festival />
      <Footer />
    </div>
  );
}

export default Home;
