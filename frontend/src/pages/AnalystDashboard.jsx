import { useState, useEffect } from 'react';
import Sidebar from '../components/Sidebar';
import DataTable from '../components/DataTable';
import StatusBadge from '../components/StatusBadge';
import API from '../api';
const NAV = [
 { path:'/', icon:'⬡', label:'Evidence' },
 { path:'/reports', icon:'≋', label:'My Findings' },
];
export default function AnalystDashboard() {
 const [evidence, setEvidence] = useState([]);
 const [selected, setSelected] = useState(null);
 const [findings, setFindings] = useState([]);
 const [newText, setNewText] = useState('');
 const [submitting, setSubmitting] = useState(false);
 const [submitErr, setSubmitErr] = useState('');
 useEffect(() => { API.get('/evidence').then(r => setEvidence(r.data)); }, []);
 const openEvidence = async (row) => {
 setSelected(row);
 const r = await API.get(`/forensic/findings/${row.evidence_id}`);
 setFindings(r.data);
 };
 const submitFinding = async () => {
 if (!newText.trim()) { setSubmitErr('Finding text cannot be empty.');
return; }
 setSubmitting(true); setSubmitErr('');
 try {
 await API.post('/forensic/findings', {
 evidence_id: selected.evidence_id,
 finding_text: newText,
 });
 setNewText('');
 openEvidence(selected);
 } catch (e) {
 setSubmitErr(e.response?.data?.error || 'Submission failed.');
 } finally { setSubmitting(false); }
 };
 const EV_COLS = [
 { key:'evidence_id', label:'ID', mono:true },
 { key:'type', label:'Type', primary:true },
 { key:'status', label:'Status', render:v=><StatusBadge status={v}/>
},
 ];
 return (
 <div style={{ display:"flex", minHeight:"100vh" }}>
 <Sidebar navItems={NAV} />
 {/* Left — evidence list */}
 <div style={{ flex:1, padding:"32px 28px 32px 40px",
 background:"var(--bg-page)", overflowY:"auto" }}>
 <h1 style={{ fontFamily:"var(--font-serif)", fontSize:"26px",
 fontWeight:"700", color:"var(--text-primary)",
marginBottom:"4px" }}>Forensic Analysis</h1>
 <p style={{ fontSize:"13px", color:"var(--text-muted)",
marginBottom:"24px" }}>
 Select an evidence item to view and record findings.
 </p>
 <DataTable columns={EV_COLS} data={evidence}
onRowClick={openEvidence} />
 </div>
 {/* Right — findings panel */}
 <div style={{
 width: "400px",
 flexShrink: 0,
 borderLeft: "1px solid var(--border-faint)",
 background: "var(--bg-surface)",
 display: "flex",
 flexDirection:"column",
 height: "100vh",
 position: "sticky",
 top: 0,
 overflowY: "auto",
 }}>
 {!selected ? (
 <div style={{ flex:1, display:"flex", alignItems:"center",
 justifyContent:"center", padding:"40px" }}>
 <p style={{ color:"var(--text-muted)", textAlign:"center",
 fontSize:"13px", lineHeight:1.7 }}>
 Select an evidence item from the list to view and
append findings.
 </p>
 </div>
 ) : (
 <>
 {/* Evidence header */}
 <div style={{ padding:"20px", borderBottom:"1px solid var(--border-faint)" }}>
 <div style={{ display:"flex",
justifyContent:"space-between",
 alignItems:"flex-start" }}>
 <div>
 <h3 style={{ fontSize:"15px", fontWeight:"600",
 color:"var(--text-primary)",
marginBottom:"3px" }}>
 {selected.type}
 </h3>
<p style={{ fontSize:"11px",
color:"var(--text-muted)",
 fontFamily:"var(--font-mono)" }}>

{String(selected.hash_value).substring(0,24)}…
 </p>
 </div>
<StatusBadge status={selected.status} />
 </div>
 </div>
 {/* Existing findings list */}
 <div style={{ flex:1, overflowY:"auto", padding:"16px 20px"
}}>
<div style={{ fontSize:"11px", fontWeight:"700",
 letterSpacing:"0.08em",
textTransform:"uppercase",
color:"var(--text-muted)",
marginBottom:"12px" }}>
 Recorded Findings ({findings.length})
 </div>
{findings.length === 0 && (
 <p style={{ color:"var(--text-muted)",
fontSize:"13px",
 textAlign:"center", padding:"24px 0"
}}>
 No findings recorded yet.
 </p>
 )}
{findings.map(f => (
 <div key={f.finding_id} style={{
 background: "var(--bg-raised)",
border: "1px solid var(--border-faint)",
 borderLeft: "3px solid var(--analysis)",
 borderRadius: "var(--r-md)",
padding: "14px",
marginBottom: "10px",
 }}>
 <p style={{ fontSize:"13px",
color:"var(--text-primary)",
 lineHeight:"1.6", marginBottom:"8px"
}}>
 {f.finding_text}
 </p>
<div style={{ fontSize:"11px",
color:"var(--text-muted)",
 fontFamily:"var(--font-mono)" }}>
 {f.reporter_name} · {new
Date(f.recorded_at).toLocaleString()}
 </div>
{/* NOTE: No edit / delete buttons — append-only design */}
 </div>
 ))}
 </div>
 {/* Append new finding */}
 <div style={{ padding:"16px 20px", borderTop:"1px solid var(--border-faint)" }}>
 <div style={{ fontSize:"11px", fontWeight:"700",
letterSpacing:"0.08em",
 textTransform:"uppercase",
color:"var(--text-muted)",
marginBottom:"6px" }}>
 Append New Finding
 </div>
<div style={{ fontSize:"11px", color:"var(--analysis)",
 marginBottom:"8px", fontStyle:"italic"
}}>
 Once submitted, this finding cannot be edited or
deleted.
 </div>
<textarea
 value={newText}
onChange={e=>setNewText(e.target.value)}
rows={4}
placeholder="Describe your forensic finding in
detail…"
style={{
 display: "block",
width: "100%",
marginBottom: "10px",
background: "var(--bg-input)",
border: "1px solid var(--border-default)",
borderRadius: "var(--r-sm)",
padding: "10px 14px",
 fontSize: "13px",
resize: "vertical",
lineHeight: "1.5",
 }}
 />
{submitErr && (
 <div style={{ fontSize:"12px", color:"#F87171",
 marginBottom:"8px"
}}>{submitErr}</div>
 )}
<button onClick={submitFinding}
 disabled={submitting || !newText.trim()}
style={{
 width: "100%",
padding: "10px",
background: (submitting||!newText.trim())
 ? "var(--border-default)"
: "var(--analysis)",
 border: "none",
borderRadius: "var(--r-sm)",
color: "#fff",
fontSize: "13px",
fontWeight: "600",
cursor: "pointer",
 }}>
 {submitting ? "Submitting…" : "Submit Finding (Permanent)"}
 </button>
 </div>
 </>
 )}
 </div>
 </div>
 );
}
