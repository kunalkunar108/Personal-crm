export type LeadStatus = "new" | "contacted" | "interested" | "proposal" | "negotiation" | "won" | "lost";
export type BusinessType = "gymos" | "website_development" | "curakart" | "other";
export type ActivityChannel = "email" | "whatsapp" | "phone" | "ai_voice" | "meeting" | "note";
export type ApprovalStatus = "draft" | "pending_approval" | "approved" | "sent" | "rejected" | "cancelled";
export interface Lead { id:string; owner_id:string; name:string; business_name:string|null; phone:string|null; email:string|null; website:string|null; business_type:BusinessType; status:LeadStatus; source:string|null; estimated_value:number|null; next_follow_up_at:string|null; created_at:string; }
export interface AgentAction { id:string; owner_id:string; action_type:string; payload:Record<string,unknown>; approval_status:ApprovalStatus; created_at:string; }