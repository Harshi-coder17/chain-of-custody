import { useState, useEffect } from 'react';
import Sidebar from '../components/Sidebar';
import DataTable from '../components/DataTable';
import StatusBadge from '../components/StatusBadge';
import CustodyTimeline from '../components/CustodyTimeline';
import API from '../api';
const NAV = [
 { path:'/', icon:'⊞', label:'Court View' },
 { path:'/audit', icon:'≋', label:'Audit Log' },
];
export default function JudicialDashboard() {
 const [courtView, setCourtView] = useState([]);
 const [auditView, setAuditView] = useState([]);
 const [activeTab, setActiveTab] = useState("court");
 const [selectedEv, setSelectedEv] = useState(null);
 const [timeline, setTimeline] = useState([]);
 useEffect(() => {
 API.get('/custody/court-view').then(r => setCourtView(r.data));
 API.get('/custody/audit-view').then(r => setAuditView(r.data));
 }, []);
 const openTimeline = async (row) => {
 setSelectedEv(row);
 const r = await API.get(`/custody/evidence/${row.evidence_id}`);
 setTimeline(r.data.map(e=>({ ...e, event_type:'CUSTODY TRANSFER',
event_text:e.action })));
 };
 const COURT_COLS = [
 { key:'case_id', label:'Case', mono:true },
 { key:'case_title', label:'Title', primary:true },
 { key:'evidence_type', label:'Evidence' },
 { key:'case_status', label:'Case Status', render:v=><StatusBadge
status={v}/> },
 { key:'evidence_status', label:'Evidence Status', render:v=><StatusBadge
status={v}/> },
 { key:'handling_officer', label:'Last Officer' },
 { key:'action_time', label:'Timestamp', render:v=>new
Date(v).toLocaleString() },
 ];
 const AUDIT_COLS = [
 { key:'evidence_id', label:'EV #', mono:true },
 { key:'evidence_type',label:'Type', primary:true },
 { key:'event_type', label:'Event',
 render:v=>(
 <span style={{ fontSize:"11px", fontWeight:"700",
 fontFamily:"var(--font-mono)", letterSpacing:"0.07em",
color: v==='CUSTODY TRANSFER' ? 'var(--accent)' :
'var(--analysis)' }}>
 {v}
 </span>
 )},
 { key:'actor', label:'Actor', primary:true },
 { key:'event_text', label:'Details' },
 { key:'event_time', label:'Time', render:v=>new
Date(v).toLocaleString() },
 ];
 return (
 <div style={{ display:"flex", minHeight:"100vh" }}>
 <Sidebar navItems={NAV} />
 <main style={{ flex:1, padding:"32px 40px", overflowY:"auto",
 background:"var(--bg-page)" }}>
 {/* Header with READ ONLY badge */}
 <div style={{ display:"flex", justifyContent:"space-between",
 alignItems:"flex-start", marginBottom:"28px" }}>
 <div>
 <h1 style={{ fontFamily:"var(--font-serif)",
fontSize:"26px",
 fontWeight:"700", color:"var(--text-primary)",
 marginBottom:"4px" }}>
 Evidence Record Verification
 </h1>
<p style={{ fontSize:"13px", color:"var(--text-muted)" }}>
 Judicial Authority Portal — View-Only Access
 </p>
 </div>
<div style={{
 padding: "6px 14px",
 background: "var(--role-judicial-bg)",
border: "1px solid rgba(217,119,6,0.3)",
 borderRadius: "100px",
fontSize: "11px",
fontWeight: "700",
color: "var(--role-judicial)",
fontFamily: "var(--font-mono)",
letterSpacing:"0.09em",
 }}>READ ONLY</div>
 </div>
 {/* Tab selector */}
 <div style={{ display:"flex", gap:"4px", marginBottom:"24px",
 background:"var(--bg-surface)", padding:"4px",
borderRadius:"var(--r-md)",
border:"1px solid var(--border-faint)",
 width:"fit-content" }}>
 {[['court','⊞ Court View'],['audit','≋ Audit Log']].map(([tab,lbl])=>(
 <button key={tab} onClick={()=>setActiveTab(tab)} style={{
 padding: "8px 20px",
 border: "none",
borderRadius: "var(--r-sm)",
fontSize: "13px",
fontWeight: "600",
cursor: "pointer",
transition: "all 0.15s",
 background: activeTab===tab ? "var(--bg-raised)" :
"transparent",
 color: activeTab===tab ? "var(--text-primary)" :
"var(--text-muted)",
 boxShadow: activeTab===tab ? "var(--shadow-sm)" :
"none",
 }}>{lbl}</button>
 ))}
 </div>
 {activeTab === "court" && (
 <div style={{ display:"grid",
 gridTemplateColumns: selectedEv ? "1fr 380px" :
"1fr",
 gap:"20px" }}>
 <DataTable columns={COURT_COLS} data={courtView}
onRowClick={openTimeline} />
 {selectedEv && (
 <div style={{
 background: "var(--bg-surface)",
border: "1px solid var(--border-default)",
 borderTop: "3px solid var(--role-judicial)",
 borderRadius: "var(--r-lg)", padding:"24px",
 height: "fit-content",
position: "sticky", top:"20px"
 }}>
 <h3 style={{ fontSize:"15px", fontWeight:"600",
 color:"var(--text-primary)",
marginBottom:"4px" }}>
 Custody Trail
 </h3>
<p style={{ fontSize:"11px",
color:"var(--text-muted)",
 fontFamily:"var(--font-mono)",
marginBottom:"16px" }}>
 {selectedEv.evidence_type} — Case
#{selectedEv.case_id}
 </p>
<CustodyTimeline events={timeline} />
 </div>
 )}
 </div>
 )}
 {activeTab === "audit" && (
 <DataTable columns={AUDIT_COLS} data={auditView} />
 )}
 </main>
 </div>
 );
}