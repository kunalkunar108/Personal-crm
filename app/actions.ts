"use server";
import {redirect} from "next/navigation";
import {z} from "zod";
import {createClient} from "@/lib/supabase/server";
const business=z.enum(["gymos","website_development","curakart","other"]);
const leadStage=z.enum(["new","contacted","interested","proposal","negotiation","won","lost"]);
const clientStage=z.enum(["onboarding","active","paused","completed","churned"]);
const payment=z.enum(["not_invoiced","pending","part_paid","paid","overdue"]);
const optText=z.string().trim().max(500).transform(v=>v||null);
const optEmail=z.string().trim().email().or(z.literal("")).transform(v=>v||null);
function v(f:FormData,k:string){return String(f.get(k)??"");}
async function owner(){const supabase=await createClient();const {data:{user},error}=await supabase.auth.getUser();if(error||!user)redirect("/login");return {supabase,user};}
export async function saveLead(f:FormData){
 const id=v(f,"id");
 const p=z.object({name:z.string().trim().min(2).max(120),business_name:optText,phone:z.string().trim().max(30).transform(x=>x||null),email:optEmail,website:z.string().trim().url().or(z.literal("")).transform(x=>x||null),business_type:business,status:leadStage,source:optText,estimated_value:z.string().trim().transform(x=>x?Number(x):null).pipe(z.number().nonnegative().max(999999999).nullable()),notes:z.string().trim().max(4000).transform(x=>x||null)}).safeParse({name:v(f,"name"),business_name:v(f,"business_name"),phone:v(f,"phone"),email:v(f,"email"),website:v(f,"website"),business_type:v(f,"business_type"),status:v(f,"status")||"new",source:v(f,"source"),estimated_value:v(f,"estimated_value"),notes:v(f,"notes")});
 if(!p.success)redirect("/leads?error=invalid");const {supabase,user}=await owner();const payload={...p.data,owner_id:user.id};
 const r=id?await supabase.from("leads").update(payload).eq("id",id).eq("owner_id",user.id).select("id").maybeSingle():await supabase.from("leads").insert(payload).select("id").single();
 if(r.error||!r.data)redirect("/leads?error=save");redirect("/leads?saved=1");
}
export async function deleteLead(f:FormData){const id=v(f,"id");if(!z.string().uuid().safeParse(id).success)redirect("/leads?error=invalid");const {supabase,user}=await owner();const {error}=await supabase.from("leads").delete().eq("id",id).eq("owner_id",user.id);if(error)redirect("/leads?error=delete");redirect("/leads?deleted=1");}
export async function saveClient(f:FormData){
 const id=v(f,"id");const p=z.object({name:z.string().trim().min(2).max(120),business_name:optText,phone:z.string().trim().max(30).transform(x=>x||null),email:optEmail,business_type:business,lifecycle_status:clientStage,payment_status:payment,contract_value:z.string().trim().transform(x=>x?Number(x):null).pipe(z.number().nonnegative().max(999999999).nullable()),notes:z.string().trim().max(4000).transform(x=>x||null)}).safeParse({name:v(f,"name"),business_name:v(f,"business_name"),phone:v(f,"phone"),email:v(f,"email"),business_type:v(f,"business_type"),lifecycle_status:v(f,"lifecycle_status")||"onboarding",payment_status:v(f,"payment_status")||"not_invoiced",contract_value:v(f,"contract_value"),notes:v(f,"notes")});
 if(!p.success)redirect("/clients?error=invalid");const {supabase,user}=await owner();const payload={...p.data,owner_id:user.id};const r=id?await supabase.from("clients").update(payload).eq("id",id).eq("owner_id",user.id).select("id").maybeSingle():await supabase.from("clients").insert(payload).select("id").single();if(r.error||!r.data)redirect("/clients?error=save");redirect("/clients?saved=1");
}
export async function deleteClient(f:FormData){const id=v(f,"id");if(!z.string().uuid().safeParse(id).success)redirect("/clients?error=invalid");const {supabase,user}=await owner();const {error}=await supabase.from("clients").delete().eq("id",id).eq("owner_id",user.id);if(error)redirect("/clients?error=delete");redirect("/clients?deleted=1");}
export async function signOut(){const supabase=await createClient();await supabase.auth.signOut();redirect("/login");}