export default function CustodyTimeline({ events = [] }) {
 if (!events.length)
 return (
 <p style={{ color:"var(--text-muted)", textAlign:"center",
padding:"32px 0", fontSize:"13px" }}>
 No events recorded yet.
 </p>
 );
 const COLORS = {
 'CUSTODY TRANSFER': 'var(--accent)',
 'FORENSIC FINDING': 'var(--analysis)',
 };
 return (
 <div style={{ padding:"4px 0" }}>
 {events.map((ev, i) => {
 const dotColor = COLORS[ev.event_type] ?? 'var(--accent)';
 return (
 <div key={i} style={{ display:"flex", gap:"14px",
position:"relative" }}>
 {/* Spine */}
 <div style={{ display:"flex", flexDirection:"column",
alignItems:"center",
 width:"24px", flexShrink:0 }}>
 <div style={{
 width:"10px", height:"10px", borderRadius:"50%",
 background: dotColor,
border: "2px solid var(--bg-surface)",
 boxShadow: `0 0 0 2px ${dotColor}33`,
 marginTop: "18px", flexShrink:0, zIndex:1,
 }} />
{i < events.length - 1 && (
 <div style={{
 width:"1px", flex:"1", minHeight:"16px",
 background:"var(--border-default)",
margin:"4px 0",
 }} />
 )}
 </div>
 {/* Event card */}
 <div style={{
 flex:1, marginBottom:"10px",
background: "var(--bg-raised)",
border: `1px solid ${dotColor}22`,
 borderRadius: "var(--r-md)",
padding: "12px 16px",
 }}>
 <div style={{ display:"flex",
justifyContent:"space-between",
 alignItems:"flex-start", gap:"8px" }}>
 <div style={{ flex:1 }}>
 <span style={{
 fontSize:"10px", fontWeight:"700",
fontFamily:"var(--font-mono)",
letterSpacing:"0.1em",
textTransform:"uppercase",
color: dotColor,
display:"block", marginBottom:"6px",
 }}>
 {ev.event_type}
 </span>
<p style={{ fontSize:"13px",
color:"var(--text-primary)",
 lineHeight:"1.55", margin:0 }}>
 {ev.event_text || ev.action}
 </p>
 </div>
 </div>
<div style={{ marginTop:"8px", display:"flex",
gap:"16px",
 flexWrap:"wrap" }}>
 <span style={{ fontSize:"11px",
color:"var(--text-muted)",
fontFamily:"var(--font-mono)" }}>
 {ev.officer_name || ev.actor}
 </span>
<span style={{ fontSize:"11px",
color:"var(--text-muted)",
 fontFamily:"var(--font-mono)" }}>
 {new Date(ev.action_time ||
ev.event_time).toLocaleString()}
 </span>
 </div>
 </div>
 </div>
 );
 })}
 </div>
 );
}