import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import LoginPage from './pages/LoginPage';
import AdminDashboard from './pages/AdminDashboard';
import OfficerDashboard from './pages/OfficerDashboard';
import AnalystDashboard from './pages/AnalystDashboard';
import JudicialDashboard from './pages/JudicialDashboard';
import './styles/globals.css';
function ProtectedRouter() {
 const { user } = useAuth();
 if (!user) return <Navigate to="/login" replace />;
 const DASHBOARDS = {
 admin: <AdminDashboard />,
 officer: <OfficerDashboard />,
 analyst: <AnalystDashboard />,
 judicial: <JudicialDashboard />,
 };
 return DASHBOARDS[user.role] ?? <Navigate to="/login" replace />;
}
export default function App() {
 return (
 <AuthProvider>
 <BrowserRouter>
 <Routes>
 <Route path="/login" element={<LoginPage />} />
 <Route path="/*" element={<ProtectedRouter />} />
 </Routes>
</BrowserRouter>
 </AuthProvider>
 );
}
