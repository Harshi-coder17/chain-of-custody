import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

const ROLE_META = {
 admin: { label:'Administrator', c:'var(--role-admin)', bg:'var(--role-admin-bg)' },
 officer: { label:'Investigating Officer', c:'var(--role-officer)', bg:'var(--role-officer-bg)' },
 analyst: { label:'Forensic Analyst', c:'var(--role-analyst)', bg:'var(--role-analyst-bg)' },
 judicial: { label:'Judicial Authority', c:'var(--role-judicial)', bg:'var(--role-judicial-bg)' },
};

export default function Sidebar({ navItems = [], onNavigate, active }) {

 const { user, logout } = useAuth();
 const nav = useNavigate();
 const meta = ROLE_META[user?.role] ?? {};

 return (
 <aside style={{
 width: "248px",
 flexShrink: 0,
 background: "var(--bg-surface)",
 borderRight: "1px solid var(--border-faint)",
 display: "flex",
 flexDirection:"column",
 height: "100vh",
 position: "sticky",
 top: 0,
 }}>

 {/* ================= HEADER ================= */}
 <div style={{ padding: "20px", borderBottom: "1px solid var(--border-faint)" }}>

 <div style={{ display:"flex", alignItems:"center", gap:"10px" }}>
   <div style={{
     width:"34px", height:"34px", borderRadius:"10px",
     background:"linear-gradient(135deg,#1E3A8A,#2563EB)",
     display:"flex", alignItems:"center", justifyContent:"center",
     fontSize:"17px"
   }}>🔒</div>

   <div>
     <div style={{ fontSize:"14px", fontWeight:"700" }}>ChainGuard</div>
     <div style={{ fontSize:"10px", color:"var(--text-muted)" }}>
       Evidence System
     </div>
   </div>
 </div>

 {/* ROLE */}
 <div style={{
 marginTop:"14px",
 background: meta.bg,
 border:`1px solid ${meta.c}30`,
 borderRadius:"var(--r-md)",
 padding:"10px 12px"
 }}>
   <div style={{ fontSize:"10px", fontWeight:"700", color:meta.c }}>
     {meta.label}
   </div>

   <div style={{ fontSize:"13px", fontWeight:"600" }}>
     {user?.name}
   </div>

   <div style={{ fontSize:"11px", color:"var(--text-muted)" }}>
     ID #{user?.officer_id}
   </div>
 </div>

 </div>

 {/* ================= NAVIGATION ================= */}
 <nav style={{ flex:1, padding:"10px 0", overflowY:"auto" }}>

 <div style={{
 fontSize:"10px",
 fontWeight:"700",
 textTransform:"uppercase",
 color:"var(--text-muted)",
 padding:"8px 20px 4px"
 }}>
 Navigation
 </div>

 {navItems.map(item => {

   // IF dashboard uses state navigation
   if (onNavigate) {
     return (
       <div
         key={item.path}
         onClick={() => onNavigate(item.path)}
         style={{
           display:"flex",
           alignItems:"center",
           gap:"10px",
           padding:"9px 20px",
           cursor:"pointer",
           fontWeight: active === item.path ? "600" : "400",
           background: active === item.path ? "var(--accent-subtle)" : "transparent",
           borderLeft: active === item.path ? "2px solid var(--accent)" : "2px solid transparent",
         }}
       >
         <span>{item.icon}</span>
         {item.label}
       </div>
     );
   }

   // ELSE fallback to router
   return (
     <NavLink
       key={item.path}
       to={item.path}
       style={({ isActive }) => ({
         display:"flex",
         alignItems:"center",
         gap:"10px",
         padding:"9px 20px",
         textDecoration:"none",
         fontWeight: isActive ? "600" : "400",
         background: isActive ? "var(--accent-subtle)" : "transparent",
         borderLeft: isActive ? "2px solid var(--accent)" : "2px solid transparent",
       })}
     >
       <span>{item.icon}</span>
       {item.label}
     </NavLink>
   );
 })}

 </nav>

 {/* ================= LOGOUT ================= */}
 <div style={{ padding:"14px 20px", borderTop:"1px solid var(--border-faint)" }}>
 <button
   onClick={() => { logout(); nav("/login"); }}
   style={{
     width:"100%",
     padding:"9px",
     border:"1px solid var(--border-default)",
     borderRadius:"var(--r-sm)",
     cursor:"pointer"
   }}
 >
   Sign Out
 </button>
 </div>

 </aside>
 );
}