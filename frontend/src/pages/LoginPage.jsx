import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import API from '../api';
export default function LoginPage() {
 const [id, setId] = useState('');
 const [pass, setPass] = useState('');
 const [err, setErr] = useState('');
 const [loading, setLoading] = useState(false);
 const { login } = useAuth();
 const nav = useNavigate();
 const handleSubmit = async (e) => {
 e.preventDefault();
 setErr(''); setLoading(true);
 try {
 const { data } = await API.post('/auth/login', {
 officer_id: id,
 password: pass,
 });
 login(data);
 nav('/');
 } catch {
 setErr('Invalid credentials. Please check your Officer ID and password.');
 } finally {
 setLoading(false);
 }
 };
 const Field = ({ label, ...props }) => (
 <div style={{ marginBottom:"18px" }}>
 <label style={{
 display:"block", fontSize:"11px", fontWeight:"700",
 letterSpacing:"0.09em", textTransform:"uppercase",
 color:"var(--text-secondary)", marginBottom:"6px"
}}>{label}</label>
 <input {...props} style={{
 display:"block", width:"100%",
 background:"var(--bg-input)",
 border:"1px solid var(--border-default)",
 borderRadius:"var(--r-sm)",
 padding:"11px 14px",
 fontSize:"14px",
 color:"var(--text-primary)",
 transition:"border-color 0.15s, box-shadow 0.15s",
 }} />
 </div>
 );
 return (
 <div style={{
 minHeight: "100vh",
 background: "var(--bg-page)",
 display: "flex",
 alignItems: "center",
 justifyContent: "center",
 backgroundImage: "radial-gradient(ellipse 80% 60% at 50% -10%,rgba(37,99,235,0.10) 0%, transparent 60%)",
 }}>
 <div style={{
 width: "400px",
 background: "var(--bg-surface)",
 border: "1px solid var(--border-default)",
 borderRadius: "var(--r-xl)",
 padding: "44px 40px",
 boxShadow: "var(--shadow-lg)",
 }}>
 {/* Header */}
 <div style={{ textAlign:"center", marginBottom:"36px" }}>
 <div style={{
 width:"56px", height:"56px", margin:"0 auto 16px",
 background:"linear-gradient(135deg,#1E3A8A,#2563EB)",
borderRadius:"16px",
display:"flex", alignItems:"center",
justifyContent:"center",
 fontSize:"24px",
boxShadow:"0 8px 24px rgba(37,99,235,0.35)"
 }}>🔒</div>
<h1 style={{
 fontFamily: "var(--font-serif)",
fontSize: "26px",
fontWeight: "700",
color: "var(--text-primary)",
marginBottom:"4px"
 }}>Chain of Custody</h1>
 <p style={{ fontSize:"13px", color:"var(--text-muted)" }}>
 Digital Evidence Management System
 </p>
 </div>
 <form onSubmit={handleSubmit}>
 <Field label="Officer ID" type="number" value={id}
 onChange={e => setId(e.target.value)} placeholder="Enter
your officer ID" />
 <Field label="Password" type="password" value={pass}
 onChange={e => setPass(e.target.value)}
placeholder="Enter your password" />
 {err && (
<div style={{
 background:"rgba(239,68,68,0.08)", border:"1px solid rgba(239,68,68,0.25)",
 borderRadius:"var(--r-sm)", padding:"10px 14px",
 fontSize:"13px", color:"#F87171", marginBottom:"16px"
 }}>{err}</div>
 )}
 <button type="submit" disabled={loading} style={{
 width: "100%",
padding: "12px",
background: loading ? "var(--border-default)" :
"var(--accent)",
 border: "none",
borderRadius: "var(--r-sm)",
color: "#fff",
fontSize: "14px",
fontWeight: "600",
cursor: loading ? "wait" : "pointer",
 boxShadow: loading ? "none" : "0 4px 14px rgba(37,99,235,0.45)",
 transition: "all 0.18s",
 marginTop: "4px",
 }}>
 {loading ? "Authenticating…" : "Authenticate"}
 </button>
 </form>
 </div>
 </div>
 );
}
