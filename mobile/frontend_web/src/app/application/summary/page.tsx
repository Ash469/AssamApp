"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import axios from "axios";
import Link from 'next/link';
import NavBar from '../../components/nav_bar';
import { FaChevronLeft } from 'react-icons/fa';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend } from "recharts";

export default function SummaryPage() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    verifiedUsers: 0,
    totalApplications: 0,
    approvedApplications: 0,
    rejectedApplications: 0,
    pendingApplications: 0,
    categoryDistribution: {} as Record<string, number>,
    districtDistribution: {} as Record<string, number>,
  });
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState("");
  const router = useRouter();

  useEffect(() => {
    // Check if the user is authenticated
    const token = localStorage.getItem('token');
    if (!token) {
      // Redirect to login page if no token exists
      router.push('/userlogin');
      return;
    }
  }, [router]);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      console.log("Fetching stats...");
      
      const [usersRes, applicationsRes] = await Promise.all([
        axios.get('/api/getnewsignup'),
        axios.get('/api/applications')
      ]);
      
      console.log("API Responses:", {
        users: usersRes.data,
        applications: applicationsRes.data
      });
      
      // Checking the actual structure of the response based on console output
      const users = usersRes.data.users || [];
      
      // The applications API appears to be returning the array directly in the 'data' property
      const applications = applicationsRes.data.data || [];
      
      console.log("Processing data:", {
        usersCount: users.length,
        applicationsCount: applications.length
      });

      const categoryDist: Record<string, number> = {};
      const districtDist: Record<string, number> = {};

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      applications.forEach((app: any) => {
        const category = app.category || 'Unknown';
        categoryDist[category] = (categoryDist[category] || 0) + 1;

        const district = app.district || 'Unknown';
        districtDist[district] = (districtDist[district] || 0) + 1;
      });

      setStats({
        totalUsers: users.length,
        verifiedUsers: users.filter((user: { verified: boolean }) => user.verified).length,
        totalApplications: applications.length,
        approvedApplications: applications.filter((app: { status: string }) => app.status === 'Approved').length,
        rejectedApplications: applications.filter((app: { status: string }) => app.status === 'Rejected').length,
        pendingApplications: applications.filter((app: { status: string }) => app.status === 'Pending').length,
        categoryDistribution: categoryDist,
        districtDistribution: districtDist,
      });
      setIsLoading(false);
    } catch (err) {
      console.error("Error fetching stats:", err);
      setIsLoading(false);
      setError("Failed to load dashboard data");
    }
  };

  const StatCard = ({ title, value, icon, color }: { title: string, value: number, icon: string, color: string }) => (
    <div className={`bg-white p-6 rounded-xl shadow-lg hover:shadow-xl transition-all border-l-4 ${color} flex justify-between items-center`}>
      <div>
        <p className="text-gray-600 text-sm font-medium">{title}</p>
        <p className="text-2xl font-bold text-gray-800 mt-1">{isLoading ? "..." : value}</p>
      </div>
      <div className={`text-3xl opacity-80`}>{icon}</div>
    </div>
  );

  const ProgressBar = ({ label, value, total, color }: { label: string, value: number, total: number, color: string }) => {
    const percentage = total > 0 ? Math.round((value / total) * 100) : 0;
    return (
      <div className="mb-4">
        <div className="flex justify-between mb-1">
          <span className="text-sm font-medium text-gray-700">{label}</span>
          <span className={`text-sm font-bold ${color}`}>{percentage}%</span>
        </div>
        <div className="w-full bg-gray-200 rounded-full h-2.5">
          <div className={`${color} h-2.5 rounded-full`} style={{ width: `${percentage}%` }}></div>
        </div>
      </div>
    );
  };

  const preparePieChartData = () => {
    if (!stats.categoryDistribution) return [];
    
    return Object.entries(stats.categoryDistribution).map(([name, value]) => ({
      name,
      value,
    }));
  };

  const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8', '#82ca9d', '#ffc658', '#8dd1e1'];

  const refresh = () => {
    setIsLoading(true);
    fetchStats();
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-teal-500"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="text-red-500 text-center">
          <p className="text-xl">{error}</p>
          <button onClick={refresh} className="mt-4 bg-teal-500 text-white px-4 py-2 rounded hover:bg-teal-600">
            Try Again
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-100">
      <NavBar />
      <section className="bg-teal-800 text-white py-10 px-6 md:px-16 flex flex-col md:flex-row items-center justify-between relative">
        {/* Back Button */}
        <Link href="/userdashboard" className="absolute top-4 left-4 md:top-6 md:left-6 flex items-center text-white bg-teal-700 hover:bg-teal-600 transition-colors px-3 py-2 rounded-lg border border-teal-500 shadow-md">
          <FaChevronLeft className="mr-1" />
          <span className="font-medium">Back</span>
        </Link>
        
        {/* Text content */}
        <div className="w-full md:w-1/2 text-center md:text-left mt-8 md:mt-0">
          <h2 className="text-3xl font-bold mb-4">Application Summary</h2>
          <p className="text-sm text-white/90">Track and analyze your application statistics</p>
        </div>

        {/* Placeholder image */}
        <div className="w-full md:w-1/2 flex justify-center mt-6 md:mt-0">
          <div className="w-64 h-40 bg-white/20 rounded-lg border border-white/50 flex items-center justify-center">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-12 w-12 text-white/80" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
          </div>
        </div>
      </section>

      <main className="container mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="bg-white p-6 rounded-xl shadow-lg mb-6">
          <h2 className="text-xl font-bold text-teal-700 mb-4">Applications Overview</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <StatCard
              title="Total Applications"
              value={stats.totalApplications}
              icon="📝"
              color="border-blue-500"
            />
            <StatCard
              title="Approved Applications"
              value={stats.approvedApplications}
              icon="✅"
              color="border-green-500"
            />
            <StatCard
              title="Pending Applications"
              value={stats.pendingApplications}
              icon="⏳"
              color="border-yellow-500"
            />
            <StatCard
              title="Rejected Applications"
              value={stats.rejectedApplications}
              icon="❌"
              color="border-red-500"
            />
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white p-6 rounded-xl shadow-lg">
            <h2 className="text-xl font-bold text-teal-700 mb-4">Application Status</h2>
            <ProgressBar 
              label="Approved" 
              value={stats.approvedApplications} 
              total={stats.totalApplications}
              color="bg-green-500 text-green-600" 
            />
            <ProgressBar 
              label="Pending" 
              value={stats.pendingApplications} 
              total={stats.totalApplications}
              color="bg-yellow-500 text-yellow-600" 
            />
            <ProgressBar 
              label="Rejected" 
              value={stats.rejectedApplications} 
              total={stats.totalApplications}
              color="bg-red-500 text-red-600" 
            />
          </div>

          <div className="bg-white p-6 rounded-xl shadow-lg">
            <h2 className="text-xl font-bold text-teal-700 mb-4">Category Distribution</h2>
            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={preparePieChartData()}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(1)}%`}
                    outerRadius={80}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {preparePieChartData().map((entry, index) => (
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

        {/* <div className="grid grid-cols-1 gap-6 mt-6">
          <div className="bg-white p-6 rounded-xl shadow-lg">
            <h2 className="text-xl font-bold text-teal-700 mb-4">Users Overview</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <StatCard
                title="Total Users"
                value={stats.totalUsers}
                icon="👥"
                color="border-purple-500"
              />
              <StatCard
                title="Verified Users"
                value={stats.verifiedUsers}
                icon="✓"
                color="border-teal-500"
              />
            </div>
          </div>
        </div> */}
      </main>
    </div>
  );
}