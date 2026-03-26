// frontend/src/components/StatusBadge.jsx
const CONFIG = {
 'Open': { color:'var(--open)', bg:'var(--open-bg)' },
 'Under Investigation':{ color:'var(--investigating)',
bg:'var(--investigating-bg)' },
 'Closed': { color:'var(--closed)', bg:'var(--closed-bg)' },
 'Collected': { color:'var(--collected)', bg:'var(--collected-bg)'
},
 'In Analysis': { color:'var(--analysis)', bg:'var(--analysis-bg)'
},
 'Stored': { color:'var(--stored)', bg:'var(--stored-bg)' },
 'Presented': { color:'var(--presented)', bg:'var(--presented-bg)'
},
};
export default function StatusBadge({ status }) {
 const cfg = CONFIG[status] ?? { color:'var(--text-muted)',
bg:'rgba(255,255,255,0.05)' };
 return (
 <span style={{
 display: "inline-flex",
 alignItems: "center",
 gap: "5px",
 padding: "3px 10px",
 borderRadius: "100px",
 background: cfg.bg,
 color: cfg.color,
 fontSize: "11px",
 fontWeight: "700",
 letterSpacing: "0.07em",
 textTransform: "uppercase",
 fontFamily: "var(--font-mono)",
 border: `1px solid ${cfg.color}38`,
 whiteSpace: "nowrap",
 }}>
 <span style={{
 width:"6px", height:"6px",
 borderRadius:"50%",
 background: cfg.color,
 flexShrink: 0,
 }} />
 {status}
 </span>
 );
}