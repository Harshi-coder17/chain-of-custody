import { useState, useEffect } from 'react';
import { Routes, Route, useNavigate } from 'react-router-dom';
import Sidebar from '../components/Sidebar';
import DataTable from '../components/DataTable';
import StatusBadge from '../components/StatusBadge';
import API from '../api';
const NAV = [
 { path:'/', icon:'◈', label:'Overview' },
 { path:'/cases', icon:'⊞', label:'Cases' },
 { path:'/evidence', icon:'⬡', label:'Evidence' },
 { path:'/officers', icon:'◉', label:'Officers' },
 { path:'/audit', icon:'≋', label:'Audit Log' },
];
// ── Stat Card ──────────────────────────────────────
function StatCard({ label, value, color, icon }) {
 return (
 <div style={{
 background: "var(--bg-surface)",
 border: "1px solid var(--border-faint)",
 borderTop: `3px solid ${color}`,
 borderRadius: "var(--r-lg)",
 padding: "22px 24px",
boxShadow: "var(--shadow-sm)",
 }}>
 <div style={{ display:"flex", justifyContent:"space-between",
alignItems:"flex-start" }}>
 <div>
 <div style={{ fontSize:"30px", fontWeight:"700", color,
marginBottom:"4px",
 fontFamily:"var(--font-mono)" }}>{value}</div>
 <div style={{ fontSize:"12px", color:"var(--text-muted)",
fontWeight:"600",
 letterSpacing:"0.06em", textTransform:"uppercase"
}}>{label}</div>
 </div>
 <div style={{ fontSize:"24px", opacity:0.5 }}>{icon}</div>
 </div>
 </div>
 );
}
// ── Main Admin Dashboard ───────────────────────────
export default function AdminDashboard() {
 const [stats, setStats] = useState({ cases:0, evidence:0, officers:0 });
 const [cases, setCases] = useState([]);
 useEffect(() => {
 Promise.all([
 API.get('/cases'),
 API.get('/evidence'),
 API.get('/officers'),
 ]).then(([c, e, o]) => {
 setStats({ cases:c.data.length, evidence:e.data.length,
officers:o.data.length });
 setCases(c.data);
 });
 }, []);
 const CASE_COLS = [
 { key:'case_id', label:'ID', mono:true },
 { key:'case_title', label:'Title', primary:true },
 { key:'start_date', label:'Date Filed' },
 { key:'status', label:'Status', render: v => <StatusBadge status={v} />
},
 ];
 return (
 <div style={{ display:"flex", minHeight:"100vh" }}>
 <Sidebar navItems={NAV} />
 <main style={{ flex:1, padding:"32px 40px", overflowY:"auto",
 background:"var(--bg-page)" }}>
 <div style={{ marginBottom:"28px" }}>
 <h1 style={{ fontFamily:"var(--font-serif)", fontSize:"28px",
 fontWeight:"700", color:"var(--text-primary)",
marginBottom:"4px" }}>System Overview</h1>
 <p style={{ color:"var(--text-muted)", fontSize:"13px" }}>
 Chain-of-Custody Digital Evidence Management
 </p>
 </div>
 {/* Stat cards */}
 <div style={{ display:"grid", gridTemplateColumns:"repeat(3,1fr)",
 gap:"16px", marginBottom:"32px" }}>
 <StatCard label='Cases' value={stats.cases}
color='var(--accent)' icon='⊞' />
 <StatCard label='Evidence' value={stats.evidence}
color='var(--analysis)' icon='⬡' />
 <StatCard label='Officers' value={stats.officers}
color='var(--role-judicial)' icon='◉' />
 </div>
 {/* Cases table */}
 <DataTable
 title="All Cases"
columns={CASE_COLS}
data={cases}
action={
 <button style={{
 padding:"8px 16px", background:"var(--accent)",
border:"none",
 borderRadius:"var(--r-sm)", color:"#fff",
fontSize:"13px",
 fontWeight:"600", cursor:"pointer",
boxShadow:"0 2px 8px rgba(37,99,235,0.4)"
 }}>+ New Case</button>
 }
 />
 </main>
 </div>
 );
}