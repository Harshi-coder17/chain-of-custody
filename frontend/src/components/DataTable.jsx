import { useState } from 'react';
export default function DataTable({ columns, data, onRowClick, title, action }) {
 const [search, setSearch] = useState('');
 const filtered = data.filter(row =>
 columns.some(col =>
 String(row[col.key] ?? '').toLowerCase()
.includes(search.toLowerCase())
 )
 );
 return (
 <div style={{
 background: "var(--bg-surface)",
 border: "1px solid var(--border-faint)",
 borderRadius: "var(--r-lg)",
 overflow: "hidden",
 boxShadow: "var(--shadow-sm)",
 }}>
 {/* Toolbar */
 <div style={{
 display: "flex",
 alignItems: "center",
 justifyContent: "space-between",
 padding: "14px 20px",
 borderBottom: "1px solid var(--border-faint)",
 gap: "12px",
 }}>
 {title && (
 <span style={{ fontSize:"14px", fontWeight:"600",
 color:"var(--text-primary)" }}>{title}</span>
 )}
 <div style={{ display:"flex", gap:"10px", marginLeft:"auto" }}>
 <input
 value={search}
onChange={e => setSearch(e.target.value)}
 placeholder="Search..."
style={{
 background: "var(--bg-input)",
border: "1px solid var(--border-default)",
 borderRadius: "var(--r-sm)",
padding: "7px 12px",
 fontSize: "13px",
width: "220px",
color: "var(--text-primary)",
 }}
 />
{action}
 </div>
 </div>}
 {/* Table */}
 <table style={{ width:"100%", borderCollapse:"collapse" }}>
 <thead>
 <tr>
 {columns.map(col => (
 <th key={col.key} style={{
 padding: "10px 16px",
 textAlign: "left",
fontSize: "11px",
fontWeight: "700",
letterSpacing: "0.08em",
textTransform: "uppercase",
color: "var(--text-muted)",
background: "var(--bg-raised)",
borderBottom: "1px solid var(--border-default)",
 }}>{col.label}</th>
 ))}
 </tr>
 </thead>
 <tbody>
    {filtered.length === 0 ? (
 <tr><td colSpan={columns.length} style={{
 padding:"32px", textAlign:"center",
color:"var(--text-muted)", fontSize:"13px"
 }}>No records found.</td></tr>
 ) : filtered.map((row, i) => (
 <tr key={i}
 onClick={() => onRowClick?.(row)}
 style={{
 borderBottom: "1px solid var(--border-faint)",
 cursor: onRowClick ? "pointer" : "default",
 transition: "background 0.12s",
 }}
onMouseEnter={e => {
 if(onRowClick) e.currentTarget.style.background =
"var(--bg-raised)";
 }}
onMouseLeave={e => {
 e.currentTarget.style.background = "transparent";
 }}
 >
 {columns.map(col => (
 <td key={col.key} style={{
 padding: "11px 16px",
 fontSize: "13px",
color: col.primary
 ? "var(--text-primary)"
: "var(--text-secondary)",
 fontFamily: col.mono ? "var(--font-mono)" :
"inherit",
 }}>
 {col.render
 ? col.render(row[col.key], row)
 : row[col.key]}
 </td>
 ))}
 </tr>
 ))}
 </tbody>
 </table>
 </div>
 );
}
