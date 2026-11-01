import type { Metadata, Viewport } from "next";
import { Archivo, Public_Sans } from "next/font/google";
import "./globals.css";

const archivo = Archivo({ subsets: ["latin"], weight: ["600", "700", "800"], variable: "--font-archivo" });
const publicSans = Public_Sans({ subsets: ["latin"], weight: ["400", "500", "600", "700"], variable: "--font-public-sans" });

export const metadata: Metadata = {
  title: { default: "Plataforma MAC", template: "%s · Plataforma MAC" },
  description: "Sistema das usinas Marcos Andrade Concreto",
  applicationName: "Plataforma MAC",
  appleWebApp: { capable: true, title: "MAC", statusBarStyle: "black-translucent" },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  viewportFit: "cover",
  themeColor: "#0b0d0a",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR" className={`${archivo.variable} ${publicSans.variable}`}>
      <body>{children}</body>
    </html>
  );
}
