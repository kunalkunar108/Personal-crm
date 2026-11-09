"use client";
import {useState} from "react";
import {createClient} from "@/lib/supabase/client";
export default function LoginForm(){
 const [email,setEmail]=useState("");const [password,setPassword]=useState("");const [error,setError]=useState("");const [busy,setBusy]=useState(false);
 async function submit(e:React.FormEvent<HTMLFormElement>){e.preventDefault();setBusy(true);setError("");try{const supabase=createClient();const {error}=await supabase.auth.signInWithPassword({email,password});if(error)throw error;const next=new URLSearchParams(window.location.search).get("next");window.location.assign(next&&next.startsWith("/")&&!next.startsWith("//")?next:"/");}catch(err){setError(err instanceof Error?err.message:"Unable to sign in.");setBusy(false);}}
 return <form className="auth-form" onSubmit={submit}><label>Email address<input type="email" autoComplete="email" required value={email} onChange={e=>setEmail(e.target.value)} placeholder="you@example.com"/></label><label>Password<input type="password" autoComplete="current-password" required minLength={8} value={password} onChange={e=>setPassword(e.target.value)} placeholder="Your password"/></label>{error&&<div className="notice error">{error}</div>}<button className="primary full" disabled={busy}>{busy?"Signing in…":"Sign in to CRM"}</button></form>;
}