import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Plataforma MAC",
    short_name: "MAC",
    description: "Sistema das usinas Marcos Andrade Concreto",
    start_url: "/",
    display: "standalone",
    orientation: "portrait",
    background_color: "#0b0d0a",
    theme_color: "#0b0d0a",
    lang: "pt-BR",
    icons: [{ src: "/icon.svg", sizes: "any", type: "image/svg+xml", purpose: "any" }],
  };
}
