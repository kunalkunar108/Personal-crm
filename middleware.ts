import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";
import { getSupabaseConfig } from "@/lib/supabase/config";
export async function middleware(request:NextRequest) {
  const config=getSupabaseConfig();
  if(!config) return NextResponse.next({request});
  let response=NextResponse.next({request});
  const supabase=createServerClient(config.url,config.key,{cookies:{
    getAll:()=>request.cookies.getAll(),
    setAll(values){values.forEach(({name,value})=>request.cookies.set(name,value));response=NextResponse.next({request});values.forEach(({name,value,options})=>response.cookies.set(name,value,options));}
  }});
  const {data}=await supabase.auth.getClaims();
  const login=request.nextUrl.pathname.startsWith("/login");
  if(!data?.claims&&!login){const url=request.nextUrl.clone();url.pathname="/login";url.searchParams.set("next",request.nextUrl.pathname);return NextResponse.redirect(url);}
  if(data?.claims&&login){const url=request.nextUrl.clone();url.pathname="/";url.search="";return NextResponse.redirect(url);}
  return response;
}
export const config={matcher:["/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)"]};