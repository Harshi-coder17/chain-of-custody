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

 // 🔥 ADD EVIDENCE STATE
 const [showAddEvidence, setShowAddEvidence] = useState(false);
 const [evForm, setEvForm] = useState({
   type: '',
   hash_value: '',
   status: 'Collected'
 });

 useEffect(() => {
   API.get('/cases').then(r => setCases(r.data));
 }, []);

 const openCase = async (row) => {
   setSelectedCase(row);
   setView("evidence");

   const r = await API.get(`/evidence?case_id=${row.case_id}`);
   setEvidence(r.data);
 };

 const openTimeline = async (row) => {
   setSelectedEv(row);
   setView("timeline");

   const r = await API.get(`/custody/evidence/${row.evidence_id}`);
   setCustodyLog(r.data.map(e => ({
     ...e,
     event_type:'CUSTODY TRANSFER',
     event_text:e.action
   })));
 };

 // 🔥 ADD EVIDENCE FUNCTION
 const handleAddEvidence = async () => {
   if (!evForm.type || !evForm.hash_value) {
     alert("Fill all fields");
     return;
   }

   try {
     await API.post('/evidence', {
       case_id: selectedCase.case_id,
       ...evForm
     });

     const r = await API.get(`/evidence?case_id=${selectedCase.case_id}`);
     setEvidence(r.data);

     setShowAddEvidence(false);
     setEvForm({
       type: '',
       hash_value: '',
       status: 'Collected'
     });

   } catch (err) {
     console.error(err);
   }
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
 render:v=><span style={{
   fontSize:11,
   color:"var(--text-muted)",
   fontFamily:"var(--font-mono)"
 }}>
 {String(v).substring(0,20)}…
 </span> },
 { key:'status', label:'Status', render:v=><StatusBadge status={v}/> },

 { key:'evidence_id', label:'',
 render:(_,row)=>(
 <button
 onClick={(e)=>{
   e.stopPropagation();
   console.log("Selected Evidence:", row); // 🔥 DEBUG
   setSelectedEv(row);
   setShowTransfer(true);
 }}
 style={{
   padding:"5px 12px",
   background:"transparent",
   border:"1px solid var(--accent)",
   borderRadius:"var(--r-sm)",
   color:"var(--accent)",
   fontSize:"11px",
   fontWeight:"600",
   cursor:"pointer"
 }}>
 Transfer
 </button>
 ) },
 ];

 return (
 <div style={{ display:"flex", minHeight:"100vh" }}>
 <Sidebar navItems={NAV} />

 <main style={{
   flex:1,
   padding:"32px 40px",
   overflowY:"auto",
   background:"var(--bg-page)"
 }}>

 {/* Navigation */}
 <div style={{ marginBottom:"24px" }}>
   {view === "cases" && <span>Cases</span>}
   {view === "evidence" && <span>{selectedCase?.case_title}</span>}
   {view === "timeline" && <span>Timeline</span>}
 </div>

 {view === "cases" && (
   <DataTable
     title="All Cases"
     columns={CASE_COLS}
     data={cases}
     onRowClick={openCase}
   />
 )}

 {view === "evidence" && (
   <>
   <DataTable
     title={`Evidence — ${selectedCase?.case_title}`}
     columns={EV_COLS}
     data={evidence}
     onRowClick={openTimeline}

     action={
       <button
         onClick={() => setShowAddEvidence(true)}
         style={{
           padding:"8px 16px",
           background:"var(--accent)",
           border:"none",
           borderRadius:"var(--r-sm)",
           color:"#fff",
           fontSize:"13px",
           fontWeight:"600",
           cursor:"pointer"
         }}
       >
         + Add Evidence
       </button>
     }
   />

   {/* ADD EVIDENCE FORM */}
   {showAddEvidence && (
     <div style={{
       marginTop:"20px",
       padding:"16px",
       border:"1px solid var(--border-default)",
       borderRadius:"var(--r-sm)",
       background:"var(--bg-surface)"
     }}>

       <input
         placeholder="Evidence Type"
         value={evForm.type}
         onChange={e => setEvForm({ ...evForm, type: e.target.value })}
         style={{ display:"block", marginBottom:"10px", width:"100%", padding:"8px" }}
       />

       <input
         placeholder="Hash Value"
         value={evForm.hash_value}
         onChange={e => setEvForm({ ...evForm, hash_value: e.target.value })}
         style={{ display:"block", marginBottom:"10px", width:"100%", padding:"8px" }}
       />

       <select
         value={evForm.status}
         onChange={e => setEvForm({ ...evForm, status: e.target.value })}
         style={{ display:"block", marginBottom:"10px", padding:"8px" }}
       >
         <option>Collected</option>
         <option>In Analysis</option>
         <option>Stored</option>
         <option>Presented</option>
       </select>

       <button onClick={handleAddEvidence}>
         Submit Evidence
       </button>

     </div>
   )}
   </>
 )}

 {view === "timeline" && (
   <CustodyTimeline events={custodyLog} />
 )}

 {showTransfer && (
   <TransferModal
     evidence={selectedEv}
     onClose={()=>setShowTransfer(false)}
     onSuccess={()=>{
       setShowTransfer(false);
       openCase(selectedCase);
     }}
   />
 )}

 </main>
 </div>
 );
}

function TransferModal({ evidence, onClose, onSuccess }) {

 const [officerId, setOfficerId] = useState('');
 const [action, setAction] = useState('');
 const [newStatus, setNewStatus] = useState('In Analysis');
 const [loading, setLoading] = useState(false);
 const [err, setErr] = useState('');

 const submit = async () => {

   // 🔥 FIX 1: Proper validation
   if (!officerId || isNaN(parseInt(officerId)) || !action) {
     setErr('Officer ID and action description are required.');
     return;
   }

   setLoading(true);
   setErr('');

   try {
     // 🔥 DEBUG (remove later if you want)
     console.log("Transfer payload:", {
       evidence_id: evidence?.evidence_id,
       officer_id: parseInt(officerId),
       action,
       new_status: newStatus,
     });

     // 🔥 FIX 2: correct parsing
     await API.post('/custody/transfer', {
       evidence_id: evidence?.evidence_id,
       officer_id: parseInt(officerId),
       action,
       new_status: newStatus,
     });

     onSuccess();

   } catch (e) {
     console.error("Transfer error:", e);

     // 🔥 FIX 3: better error handling
     setErr(e.response?.data?.error || 'Transfer failed.');
   } finally {
     setLoading(false);
   }
 };

 return (
 <div style={{
   position:"fixed",
   inset:0,
   background:"var(--bg-overlay)",
   display:"flex",
   alignItems:"center",
   justifyContent:"center",
   zIndex:1000,
   padding:"20px"
 }}>

 <div style={{
   width:"460px",
   background:"var(--bg-surface)",
   border:"1px solid var(--border-strong)",
   borderRadius:"var(--r-xl)",
   padding:"32px",
   boxShadow:"var(--shadow-lg)",
 }}>

 <h3 style={{
   fontSize:"18px",
   fontWeight:"700",
   color:"var(--text-primary)",
   marginBottom:"6px"
 }}>
   Transfer Custody
 </h3>

 <p style={{
   fontSize:"13px",
   color:"var(--text-muted)",
   marginBottom:"24px"
 }}>
   Evidence:
   <span style={{
     color:"var(--text-primary)",
     fontFamily:"var(--font-mono)",
     marginLeft:"6px"
   }}>
     {evidence?.type}
   </span>
 </p>

 {/* Inputs */}
 {[
   ['Receiving Officer ID', officerId, setOfficerId, 'number', 'e.g. 3'],
   ['Action / Reason', action, setAction, 'text', 'e.g. Sent to Lab'],
 ].map(([lbl,val,setter,type,ph])=>(
   <div key={lbl} style={{ marginBottom:"16px" }}>
     <label style={{
       display:"block",
       fontSize:"11px",
       fontWeight:"700",
       letterSpacing:"0.09em",
       textTransform:"uppercase",
       marginBottom:"6px"
     }}>
       {lbl}
     </label>

     <input
       type={type}
       value={val}
       onChange={e=>setter(e.target.value)}
       placeholder={ph}
       style={{
         width:"100%",
         padding:"10px",
         border:"1px solid var(--border-default)",
         borderRadius:"var(--r-sm)"
       }}
     />
   </div>
 ))}

 {/* Status */}
 <select
   value={newStatus}
   onChange={e=>setNewStatus(e.target.value)}
   style={{
     width:"100%",
     padding:"10px",
     marginBottom:"20px",
     border:"1px solid var(--border-default)",
     borderRadius:"var(--r-sm)"
   }}
 >
   <option>Collected</option>
   <option>In Analysis</option>
   <option>Stored</option>
   <option>Presented</option>
 </select>

 {/* Error */}
 {err && (
   <div style={{
     background:"rgba(239,68,68,0.08)",
     border:"1px solid rgba(239,68,68,0.25)",
     padding:"10px",
     color:"#F87171",
     marginBottom:"16px"
   }}>
     {err}
   </div>
 )}

 {/* Buttons */}
 <div style={{ display:"flex", gap:"12px" }}>
   <button
     onClick={submit}
     disabled={loading}
     style={{
       flex:1,
       padding:"11px",
       background:"var(--accent)",
       color:"#fff",
       border:"none",
       borderRadius:"var(--r-sm)",
       cursor:"pointer"
     }}
   >
     {loading ? "Transferring…" : "Confirm Transfer"}
   </button>

   <button
     onClick={onClose}
     style={{
       flex:1,
       padding:"11px",
       border:"1px solid var(--border-default)",
       borderRadius:"var(--r-sm)"
     }}
   >
     Cancel
   </button>
 </div>

 </div>
 </div>
 );
}