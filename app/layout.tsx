import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Curakart AI CRM",
  description: "AI-powered sales workspace for Curakart Technologies.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body>{children}</body></html>;
}
