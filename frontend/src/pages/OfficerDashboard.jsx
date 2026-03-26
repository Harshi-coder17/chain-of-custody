import { useState, useEffect } from 'react';
import Sidebar from '../components/Sidebar';
import DataTable from '../components/DataTable';
import StatusBadge from '../components/StatusBadge';
import CustodyTimeline from '../components/CustodyTimeline';
import API from '../api';
const NAV = [
 { path:'/', icon:'⊞', label:'My Cases' },
 { path:'/evidence', icon:'⬡', label:'Evidence' },
 { path:'/custody', icon:'↕', label:'Custody Log' },
];
export default function OfficerDashboard() {
 const [cases, setCases] = useState([]);
 const [selectedCase, setSelectedCase] = useState(null);
 const [evidence, setEvidence] = useState([]);
 const [selectedEv, setSelectedEv] = useState(null);
 const [custodyLog, setCustodyLog] = useState([]);
 const [view, setView] = useState("cases");
 const [showTransfer, setShowTransfer] = useState(false);
 useEffect(() => { API.get('/cases').then(r => setCases(r.data)); }, []);
 const openCase = async (row) => {
 setSelectedCase(row); setView("evidence");
 const r = await API.get(`/evidence?case_id=${row.case_id}`);
 setEvidence(r.data);
 };
const openTimeline = async (row) => {
 setSelectedEv(row); setView("timeline");
 const r = await API.get(`/custody/evidence/${row.evidence_id}`);
 // Map to Audit_View-style format for CustodyTimeline
 setCustodyLog(r.data.map(e => ({ ...e, event_type:'CUSTODY TRANSFER',
event_text:e.action })));
 };
 const CASE_COLS = [
 { key:'case_id', label:'ID', mono:true },
 { key:'case_title', label:'Title', primary:true },
 { key:'start_date', label:'Filed' },
 { key:'status', label:'Status', render:v=><StatusBadge status={v}/> },
 ];
 const EV_COLS = [
 { key:'evidence_id', label:'ID', mono:true },
 { key:'type', label:'Type', primary:true },
 { key:'hash_value', label:'Hash', mono:true,
 render:v=><span
style={{fontSize:11,color:"var(--text-muted)",fontFamily:"var(--font-mono)"}}>
 {String(v).substring(0,20)}…</span> },
 { key:'status', label:'Status', render:v=><StatusBadge status={v}/> },
 { key:'evidence_id', label:'',
 render:(_,row)=>(
 <button
onClick={e=>{e.stopPropagation();setSelectedEv(row);setShowTransfer(true);}}
 style={{ padding:"5px 12px", background:"transparent",
 border:"1px solid var(--accent)",
borderRadius:"var(--r-sm)",
 color:"var(--accent)", fontSize:"11px",
fontWeight:"600",
 cursor:"pointer", fontFamily:"var(--font-mono)" }}>
 Transfer
 </button>
 ) },
 ];
 return (
 <div style={{ display:"flex", minHeight:"100vh" }}>
 <Sidebar navItems={NAV} />
 <main style={{ flex:1, padding:"32px 40px", overflowY:"auto",
 background:"var(--bg-page)" }}>
 {/* Breadcrumb navigation */}
 <div style={{ display:"flex", gap:"8px", alignItems:"center",
 marginBottom:"24px", fontSize:"13px" }}>
 <span style={{
color:view!="cases"?"var(--accent)":"var(--text-muted)",
 cursor:view!="cases"?"pointer":"default" }}
 onClick={()=>setView("cases")}>Cases</span>
 {view !== "cases" && (
 <>
 <span style={{ color:"var(--text-muted)" }}>/</span>
 <span style={{

color:view==="timeline"?"var(--accent)":"var(--text-primary)",
cursor:view==="timeline"?"pointer":"default" }}
onClick={()=>setView("evidence")}>
{selectedCase?.case_title}
 </span>
 </>
 )}
{view === "timeline" && (
 <>
 <span style={{ color:"var(--text-muted)" }}>/</span>
 <span style={{ color:"var(--text-primary)" }}>
 Timeline — {selectedEv?.type}
 </span>
 </>
 )}
 </div>
 {view === "cases" && (
 <DataTable title="All Cases" columns={CASE_COLS} 
 data={cases} onRowClick={openCase} />
 )}
 {view === "evidence" && (
 <DataTable
 title={`Evidence — ${selectedCase?.case_title}`}
 columns={EV_COLS}
data={evidence}
onRowClick={openTimeline}
action={
 <button style={{ padding:"8px 16px",
background:"var(--accent)",
 border:"none", borderRadius:"var(--r-sm)",
color:"#fff",
 fontSize:"13px", fontWeight:"600", cursor:"pointer"
}}>
 + Add Evidence
 </button>
 }
 />
 )}
 {view === "timeline" && (
 <div style={{ maxWidth:"660px" }}>
 <div style={{ background:"var(--bg-surface)",
 border:"1px solid var(--border-default)",
 borderRadius:"var(--r-lg)", padding:"24px",
borderTop:"3px solid var(--accent)" }}>
 <h2 style={{ fontSize:"17px", fontWeight:"600",
 color:"var(--text-primary)",
marginBottom:"4px" }}>
 Custody Timeline
 </h2>
<p style={{ fontSize:"12px", color:"var(--text-muted)",
 fontFamily:"var(--font-mono)",
marginBottom:"20px" }}>
 {selectedEv?.type} —
{String(selectedEv?.hash_value).substring(0,24)}…
 </p>
<CustodyTimeline events={custodyLog} />
 </div>
 </div>
 )}
 {showTransfer && (
 <TransferModal
 evidence={selectedEv}
onClose={()=>setShowTransfer(false)}
onSuccess={()=>{ setShowTransfer(false);
openCase(selectedCase); }}
 />
 )}
 </main>
 </div>
 );
}
// ── Transfer Custody Modal ─────────────────────────
function TransferModal({ evidence, onClose, onSuccess }) {
 const [officerId, setOfficerId] = useState('');
 const [action, setAction] = useState('');
 const [newStatus, setNewStatus] = useState('In Analysis');
 const [loading, setLoading] = useState(false);
 const [err, setErr] = useState('');
 const submit = async () => {
 if (!officerId || !action) {
 setErr('Officer ID and action description are required.'); return;
 }
 setLoading(true);
 try {
 await API.post('/custody/transfer', {
 evidence_id: evidence.evidence_id,
 officer_id: Number(officerId),
 action,
 new_status: newStatus,
 });
 onSuccess();
 } catch (e) {
 setErr(e.response?.data?.error || 'Transfer failed.');
 } finally { setLoading(false); }
 };
 return (
 <div style={{ position:"fixed", inset:0, background:"var(--bg-overlay)",
 display:"flex", alignItems:"center", justifyContent:"center",
 zIndex:1000, padding:"20px" }}>
 <div style={{
 width:"460px", background:"var(--bg-surface)",
 border:"1px solid var(--border-strong)",
 borderRadius:"var(--r-xl)", padding:"32px",
 boxShadow:"var(--shadow-lg)",
 }}>
 <h3 style={{ fontSize:"18px", fontWeight:"700",
 color:"var(--text-primary)", marginBottom:"6px" }}>
 Transfer Custody
 </h3>
 <p style={{ fontSize:"13px", color:"var(--text-muted)",
marginBottom:"24px" }}>
 Evidence: <span style={{ color:"var(--text-primary)",
 fontFamily:"var(--font-mono)", fontSize:12
}}>{evidence?.type}</span>
 </p>
 {[
 ['Receiving Officer ID', officerId, setOfficerId, 'number',
'e.g. 3'],
 ['Action / Reason', action, setAction, 'text',
'e.g. Transferred to Forensics Lab'],
 ].map(([lbl,val,setter,type,ph])=>(
 <div key={lbl} style={{ marginBottom:"16px" }}>
 <label style={{ display:"block", fontSize:"11px",
fontWeight:"700",
 letterSpacing:"0.09em",
textTransform:"uppercase",
color:"var(--text-secondary)",
marginBottom:"6px" }}>
 {lbl}
 </label>
<input type={type} value={val}
onChange={e=>setter(e.target.value)}
 placeholder={ph}
style={{ display:"block", width:"100%",
 background:"var(--bg-input)",
border:"1px solid var(--border-default)",
 borderRadius:"var(--r-sm)",
padding:"10px 14px", fontSize:"14px" }} />
 </div>
 ))}
 <div style={{ marginBottom:"24px" }}>
 <label style={{ display:"block", fontSize:"11px",
fontWeight:"700",
 letterSpacing:"0.09em",
textTransform:"uppercase",
color:"var(--text-secondary)",
marginBottom:"6px" }}>
 New Evidence Status
 </label>
<select value={newStatus}
onChange={e=>setNewStatus(e.target.value)}
 style={{ display:"block", width:"100%",
 background:"var(--bg-input)",
border:"1px solid var(--border-default)",
 borderRadius:"var(--r-sm)", padding:"10px 14px",
 fontSize:"14px" }}>
 <option>Collected</option>
<option>In Analysis</option>
<option>Stored</option>
<option>Presented</option>
 </select>
 </div>
 {err && (<div style={{ background:"rgba(239,68,68,0.08)",
 border:"1px solid rgba(239,68,68,0.25)",
borderRadius:"var(--r-sm)",
 padding:"10px 14px", fontSize:"13px", color:"#F87171",
 marginBottom:"16px" }}>{err}</div>)}
 <div style={{ display:"flex", gap:"12px" }}>
 <button onClick={submit} disabled={loading} style={{
 flex:1, padding:"11px", background:"var(--accent)",
 border:"none", borderRadius:"var(--r-sm)", color:"#fff",
 fontSize:"14px", fontWeight:"600", cursor:"pointer",
 boxShadow:"0 3px 10px rgba(37,99,235,0.4)" }}>
 {loading ? "Transferring…" : "Confirm Transfer"}
 </button>
<button onClick={onClose} style={{
 flex:1, padding:"11px", background:"transparent",
 border:"1px solid var(--border-default)",
borderRadius:"var(--r-sm)",
 color:"var(--text-secondary)", fontSize:"14px",
cursor:"pointer" }}>
 Cancel
 </button>
 </div>
 </div>
 </div>
 );
}