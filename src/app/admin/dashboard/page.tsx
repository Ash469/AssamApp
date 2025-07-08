"use client";
import { useEffect, useState } from "react";
import axios from "axios";
import Footer from "@/app/components/footer";
import Image from "next/image";
import { FaSync, FaClock, FaUsers, FaFileAlt, FaCheckCircle } from "react-icons/fa";
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend } from "recharts";
import AdminRouteProtection from "@/app/components/AdminRouteProtection";

export default function AdminHome() {
  const [adminName, setAdminName] = useState("Admin");
  const [totalUsers, setTotalUsers] = useState(0);
  const [verifiedUsers, setVerifiedUsers] = useState(0);
  const [pendingUsers, setPendingUsers] = useState(0);
  const [totalApplications, setTotalApplications] = useState(0);
  const [approvedApplications, setApprovedApplications] = useState(0);
  const [rejectedApplications, setRejectedApplications] = useState(0);
  const [pendingApplications, setPendingApplications] = useState(0);
  const [categoryDistribution, setCategoryDistribution] = useState<Record<string, number>>({});
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    loadAdminData();
    fetchDashboardData();
  }, []);

  const loadAdminData = () => {
    const userDataString = localStorage.getItem("userData");
    if (userDataString) {
      const userData = JSON.parse(userDataString);
      setAdminName(userData.firstName || "Admin");
    }
  };

  const fetchDashboardData = async () => {
    setIsLoading(true);
    try {
      const [usersRes, applicationsRes] = await Promise.all([
        axios.get('/api/getnewsignup'),
        axios.get('/api/applications')
      ]);

      const users = usersRes.data.users || [];
      const applications = applicationsRes.data.data || [];

      const verified = users.filter((user: { verified: boolean }) => user.verified).length;
      const pending = users.filter((user: { verified: boolean }) => !user.verified).length;
      setTotalUsers(users.length);
      setVerifiedUsers(verified);
      setPendingUsers(pending);

      const approved = applications.filter((app: { status: string }) => app.status === 'Approved').length;
      const rejected = applications.filter((app: { status: string }) => app.status === 'Rejected').length;
      const pendingApps = applications.filter((app: { status: string }) => app.status === 'Pending').length;
      setTotalApplications(applications.length);
      setApprovedApplications(approved);
      setRejectedApplications(rejected);
      setPendingApplications(pendingApps);

      const catDist: Record<string, number> = {};
      applications.forEach((app: { category: string }) => {
        const category = app.category || 'Unknown';
        catDist[category] = (catDist[category] || 0) + 1;
      });
      setCategoryDistribution(catDist);

      setIsLoading(false);
    } catch (err) {
      console.error("Error fetching dashboard data:", err);
      setError("Failed to load dashboard data");
      setIsLoading(false);
    }
  };

  return (
    <AdminRouteProtection>
      <div className="flex flex-col min-h-screen bg-gray-100">
        <header 
          className="relative min-h-[250px] sm:h-[300px] bg-cover bg-center" 
          style={{ 
            backgroundImage: "linear-gradient(rgba(13, 148, 136, 0.9), rgba(13, 148, 136, 0.8)), url(/app_bar.png)"
          }}
        >
          <div className="container mx-auto px-4 sm:px-8">
            <div className="flex flex-col sm:flex-row justify-between items-center py-6">
              <div className="flex flex-col sm:flex-row items-center gap-4 text-center sm:text-left">
                <Image 
                  src="/logo.png" 
                  alt="Logo" 
                  width={128}
                  height={128}
                  className="w-24 h-24 sm:w-32 sm:h-32 rounded-xl border-4 border-white shadow-2xl" 
                />
                <div className="mt-4 sm:mt-0 sm:ml-4">
                  <h1 className="text-3xl sm:text-5xl font-bold text-white tracking-wide">
                    Welcome {adminName}
                  </h1>
                  <p className="text-xl sm:text-2xl text-teal-100 mt-2">
                    Admin Dashboard
                  </p>
                </div>
              </div>
              
              <button 
                className="mt-6 sm:mt-0 bg-white/10 hover:bg-white/20 text-white px-6 sm:px-8 py-3 rounded-lg flex items-center gap-3 backdrop-blur-sm transition-all border-2 border-white/20 shadow-lg w-full sm:w-auto justify-center"
                onClick={() => window.location.href = "/admin/profile"}
              >
                <i className="fas fa-user-shield text-xl sm:text-2xl"></i>
                <span className="text-base sm:text-lg font-semibold">My Profile</span>
              </button>
            </div>
          </div>
        </header>

        {isLoading ? (
          <div className="flex-grow flex items-center justify-center">
            <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-teal-500"></div>
          </div>
        ) : error ? (
          <div className="flex-grow flex items-center justify-center">
            <div className="text-red-500 text-center">
              <p className="text-xl">{error}</p>
              <button onClick={fetchDashboardData} className="mt-4 bg-teal-500 text-white px-4 py-2 rounded hover:bg-teal-600">
                Try Again
              </button>
            </div>
          </div>
        ) : (
          <main className="relative -mt-24 sm:-mt-34 z-10 container mx-auto px-4 sm:px-8 flex-grow">
            <div className="bg-white rounded-2xl shadow-xl p-4 sm:p-8 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
              {menuItems.map((item, i) => (
                <div
                  key={i}
                  onClick={() => window.location.href = item.link}
                  className="cursor-pointer flex flex-col items-center p-4 sm:p-6 rounded-xl bg-teal-50 hover:bg-teal-100 transition-all duration-300 border border-teal-200 shadow-md hover:shadow-lg"
                >
                  <div className="text-teal-600 text-3xl sm:text-4xl mb-3">
                    {item.icon()}
                  </div>
                  <p className="text-base sm:text-lg font-medium text-center text-teal-800">{item.label}</p>
                </div>
              ))}
            </div>

            <div className="mt-6 sm:mt-10 mb-6">
              <div className="flex justify-between items-center mb-4">
                <h2 className="text-lg font-semibold text-black">Dashboard Overview</h2>
                <button 
                  onClick={fetchDashboardData}
                  className="flex items-center gap-2 bg-teal-50 hover:bg-teal-100 text-teal-700 px-3 py-1 rounded-lg text-sm transition-all border border-teal-200"
                >
                  <FaSync className={`${isLoading ? 'animate-spin' : ''}`} />
                  {isLoading ? 'Refreshing...' : 'Refresh'}
                </button>
              </div>
            
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <div className="bg-white p-5 rounded-xl shadow-md border border-gray-100">
                  <h3 className="text-md font-semibold text-gray-700 mb-4">User Status Overview</h3>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <EnhancedStatCard 
                      title="Total Users" 
                      value={totalUsers.toString()} 
                      icon={<FaUsers className="text-blue-500" />}
                      trend={totalUsers > 0 ? "+1" : "0"}
                    />
                    <EnhancedStatCard 
                      title="Pending Approval" 
                      value={pendingUsers.toString()} 
                      icon={<FaClock className="text-amber-500" />}
                      trend={pendingUsers > 0 ? `${Math.round((pendingUsers/totalUsers) * 100)}%` : "0%"}
                    />
                  </div>
                  <div className="mt-4">
                    <ProgressBar 
                      label="Verified Users" 
                      value={verifiedUsers} 
                      total={totalUsers}
                      color="bg-teal-500" 
                      textColor="text-teal-700"
                    />
                    <ProgressBar 
                      label="Pending Users" 
                      value={pendingUsers} 
                      total={totalUsers}
                      color="bg-amber-500" 
                      textColor="text-amber-700"
                    />
                  </div>
                </div>

                <div className="bg-white p-5 rounded-xl shadow-md border border-gray-100">
                  <h3 className="text-md font-semibold text-gray-700 mb-4">Application Status</h3>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <EnhancedStatCard 
                      title="Total Applications" 
                      value={totalApplications.toString()} 
                      icon={<FaFileAlt className="text-indigo-500" />}
                      trend={totalApplications > 0 ? "+2" : "0"}
                    />
                    <EnhancedStatCard 
                      title="Approved Applications" 
                      value={approvedApplications.toString()} 
                      icon={<FaCheckCircle className="text-green-500" />}
                      trend={`${totalApplications > 0 ? Math.round((approvedApplications/totalApplications) * 100) : 0}%`}
                    />
                  </div>
                  <div className="mt-4">
                    <ProgressBar 
                      label="Approved" 
                      value={approvedApplications} 
                      total={totalApplications}
                      color="bg-green-500" 
                      textColor="text-green-700"
                    />
                    <ProgressBar 
                      label="Pending" 
                      value={pendingApplications} 
                      total={totalApplications}
                      color="bg-yellow-500" 
                      textColor="text-yellow-700"
                    />
                    <ProgressBar 
                      label="Rejected" 
                      value={rejectedApplications} 
                      total={totalApplications}
                      color="bg-red-500" 
                      textColor="text-red-700"
                    />
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
                <div className="bg-white p-5 rounded-xl shadow-md border border-gray-100">
                  <h3 className="text-md font-semibold text-gray-700 mb-4">Verification Status</h3>
                  <div className="flex justify-center items-center h-48">
                    <div className="relative w-40 h-40">
                      <svg className="w-full h-full" viewBox="0 0 36 36">
                        <path
                          d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                          fill="none"
                          stroke="#E5E7EB"
                          strokeWidth="3"
                          strokeLinecap="round"
                        />
                        <path
                          d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                          fill="none"
                          stroke="#0D9488"
                          strokeWidth="3"
                          strokeLinecap="round"
                          strokeDasharray={`${totalUsers > 0 ? (verifiedUsers / totalUsers) * 100 : 0}, 100`}
                        />
                      </svg>
                      <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 text-center">
                        <p className="text-3xl font-bold text-teal-700">
                          {totalUsers > 0 ? Math.round((verifiedUsers / totalUsers) * 100) : 0}%
                        </p>
                        <p className="text-xs text-gray-500">Verified</p>
                      </div>
                    </div>
                  </div>
                  <div className="flex justify-between items-center text-sm text-gray-600 mt-4">
                    <div className="flex items-center gap-2">
                      <div className="w-3 h-3 rounded-full bg-teal-500"></div>
                      <span>Verified ({verifiedUsers})</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <div className="w-3 h-3 rounded-full bg-gray-300"></div>
                      <span>Pending ({pendingUsers})</span>
                    </div>
                  </div>
                </div>

                <div className="bg-white p-5 rounded-xl shadow-md border border-gray-100">
                  <h3 className="text-md font-semibold text-gray-700 mb-4">Category Distribution</h3>
                  <div className="h-64">
                    <ResponsiveContainer width="100%" height="100%">
                      <PieChart>
                        <Pie
                          data={Object.entries(categoryDistribution).map(([name, value]) => ({ name, value }))}
                          cx="50%"
                          cy="50%"
                          labelLine={false}
                          label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(1)}%`}
                          outerRadius={80}
                          fill="#8884d8"
                          dataKey="value"
                        >
                          {Object.keys(categoryDistribution).map((_, index) => (
                            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                          ))}
                        </Pie>
                        <Tooltip formatter={(value, name) => [`${value} applications`, name]} />
                        <Legend />
                      </PieChart>
                    </ResponsiveContainer>
                  </div>
                </div>
              </div>
            </div>
          </main>
        )}
        <div className="py-6 sm:py-3"></div>
        <Footer />
      </div>
    </AdminRouteProtection>
  );
}

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8', '#82ca9d', '#ffc658', '#8dd1e1'];

const EnhancedStatCard = ({ title, value, icon, trend }: { title: string, value: string, icon: React.ReactNode, trend: string }) => (
  <div className="bg-white p-3 sm:p-4 rounded-lg shadow-sm flex items-center gap-3 border border-gray-100 hover:border-teal-200 transition-all">
    <div className="p-2 bg-gray-50 rounded-lg">
      {icon}
    </div>
    <div className="flex-1">
      <p className="text-xs text-gray-500 font-medium">{title}</p>
      <div className="flex items-center justify-between">
        <p className="text-lg font-bold text-gray-800">{value}</p>
        <span className="text-xs font-medium text-teal-600">{trend}</span>
      </div>
    </div>
  </div>
);

const ProgressBar = ({ label, value, total, color, textColor }: { label: string, value: number, total: number, color: string, textColor: string }) => {
  const percentage = total > 0 ? Math.round((value / total) * 100) : 0;
  return (
    <div className="mb-3">
      <div className="flex justify-between items-center mb-1">
        <span className="text-xs font-medium text-gray-500">{label}</span>
        <div className="flex items-center">
          <span className={`text-xs font-bold ${textColor}`}>{value}</span>
          <span className="text-xs text-gray-400 ml-1">/ {total}</span>
        </div>
      </div>
      <div className="w-full bg-gray-200 rounded-full h-1.5">
        <div className={`${color} h-1.5 rounded-full`} style={{ width: `${percentage}%` }}></div>
      </div>
    </div>
  );
};

const menuItems = [
  {
    label: "Application Management",
    icon: () => <i className="fas fa-file-alt"></i>,
    link: "/admin/application"
  },
  {
    label: "Notification Management",
    icon: () => <i className="fas fa-bell"></i>,
    link: "/admin/notification"
  },
  {
    label: "User Management",
    icon: () => <i className="fas fa-users"></i>,
    link: "/admin/user"
  }
];
