import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = { title: "Personal CRM | AI Sales Desk", description: "A private command center for leads, clients, follow-ups, and sales activity." };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) { return <html lang="en"><body>{children}</body></html>; }