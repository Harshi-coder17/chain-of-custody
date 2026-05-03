import { useState, useEffect } from 'react';
import Sidebar from '../components/Sidebar';
import DataTable from '../components/DataTable';
import StatusBadge from '../components/StatusBadge';
import API from '../api';

const NAV = [
 { path:'overview', icon:'◈', label:'Overview' },
 { path:'cases', icon:'⊞', label:'Cases' },
 { path:'evidence', icon:'⬡', label:'Evidence' },
 { path:'officers', icon:'◉', label:'Officers' },
 { path:'audit', icon:'≋', label:'Audit Log' },
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
 <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-start" }}>
 <div>
 <div style={{
 fontSize:"30px",
 fontWeight:"700",
 color,
 marginBottom:"4px",
 fontFamily:"var(--font-mono)"
 }}>{value}</div>

 <div style={{
 fontSize:"12px",
 color:"var(--text-muted)",
 fontWeight:"600",
 letterSpacing:"0.06em",
 textTransform:"uppercase"
 }}>{label}</div>
 </div>

 <div style={{ fontSize:"24px", opacity:0.5 }}>{icon}</div>
 </div>
 </div>
 );
}

// ── Main Admin Dashboard ───────────────────────────
export default function AdminDashboard() {

 const [view, setView] = useState('overview');

 const [stats, setStats] = useState({ cases:0, evidence:0, officers:0 });
 const [cases, setCases] = useState([]);
 const [evidence, setEvidence] = useState([]);
 const [officers, setOfficers] = useState([]);

 const [showForm, setShowForm] = useState(false);
 const [form, setForm] = useState({
   case_title: '',
   description: '',
   start_date: '',
   status: 'Open'
 });

 useEffect(() => {
   fetchData();
 }, []);

 const fetchData = async () => {
   const [c, e, o] = await Promise.all([
     API.get('/cases'),
     API.get('/evidence'),
     API.get('/officers'),
   ]);

   setStats({
     cases: c.data.length,
     evidence: e.data.length,
     officers: o.data.length
   });

   setCases(c.data);
   setEvidence(e.data);
   setOfficers(o.data);
 };

 const handleAddCase = async () => {
   if (!form.case_title || !form.description || !form.start_date) {
     alert("Please fill all fields");
     return;
   }

   try {
     await API.post('/cases', form);
     await fetchData();

     setShowForm(false);
     setForm({
       case_title: '',
       description: '',
       start_date: '',
       status: 'Open'
     });

   } catch (err) {
     console.error(err);
   }
 };

 const CASE_COLS = [
 { key:'case_id', label:'ID' },
 { key:'case_title', label:'Title' },
 { key:'start_date', label:'Date Filed' },
 { key:'status', label:'Status', render: v => <StatusBadge status={v} /> },
 ];

 const EV_COLS = [
 { key:'evidence_id', label:'ID' },
 { key:'type', label:'Type' },
 { key:'status', label:'Status', render:v=><StatusBadge status={v}/> },
 ];

 const OFF_COLS = [
 { key:'officer_id', label:'ID' },
 { key:'name', label:'Name' },
 { key:'role', label:'Role' },
 { key:'department', label:'Department' },
 ];

 return (
 <div style={{ display:"flex", minHeight:"100vh" }}>

 <Sidebar
   navItems={NAV}
   onNavigate={(p)=>setView(p)}
   active={view}
 />

 <main style={{
 flex:1,
 padding:"32px 40px",
 overflowY:"auto",
 background:"var(--bg-page)"
 }}>

 {/* OVERVIEW */}
 {view === 'overview' && (
 <>
 <div style={{ marginBottom:"28px" }}>
 <h1>System Overview</h1>
 </div>

 <div style={{
 display:"grid",
 gridTemplateColumns:"repeat(3,1fr)",
 gap:"16px",
 marginBottom:"32px"
 }}>
 <StatCard label='Cases' value={stats.cases} color='var(--accent)' icon='⊞' />
 <StatCard label='Evidence' value={stats.evidence} color='var(--analysis)' icon='⬡' />
 <StatCard label='Officers' value={stats.officers} color='var(--role-judicial)' icon='◉' />
 </div>
 </>
 )}

 {/* CASES */}
 {view === 'cases' && (
 <DataTable
   title="All Cases"
   columns={CASE_COLS}
   data={cases}
   action={
   <button
     onClick={() => setShowForm(true)}
     style={{
       padding:"8px 16px",
       background:"var(--accent)",
       border:"none",
       borderRadius:"var(--r-sm)",
       color:"#fff",
       cursor:"pointer"
     }}
   >
   + New Case
   </button>
   }
 />
 )}

 {/* EVIDENCE */}
 {view === 'evidence' && (
 <DataTable
   title="All Evidence"
   columns={EV_COLS}
   data={evidence}
 />
 )}

 {/* OFFICERS */}
 {view === 'officers' && (
 <DataTable
   title="All Officers"
   columns={OFF_COLS}
   data={officers}
 />
 )}

 {/* AUDIT */}
 {view === 'audit' && (
 <div>
   <h2>Audit Log</h2>
   <p>Connect custody logs here</p>
 </div>
 )}

 {/* FORM */}
 {showForm && (
 <div style={{
   marginTop:"20px",
   padding:"16px",
   border:"1px solid var(--border-default)"
 }}>
   <input placeholder="Case Title"
     onChange={e => setForm({ ...form, case_title: e.target.value })}
   />
   <br></br>
   <br></br>
   <input placeholder="Description"
     onChange={e => setForm({ ...form, description: e.target.value })}
   />
   <br></br>
   <br></br>
   <input type="date"
     onChange={e => setForm({ ...form, start_date: e.target.value })}
   />
   <br></br>
   <br></br>
   <button onClick={handleAddCase}>Submit</button>
 </div>
 )}

 </main>
 </div>
 );
}