'use client';

import React, { useEffect, useState } from 'react';
import { FaSync, FaFilter, FaEye, FaTimes, FaCheck } from 'react-icons/fa';
import Image from 'next/image';
import Footer from '@/app/components/footer';
import AdminRouteProtection from '@/app/components/AdminRouteProtection';

interface User {
  id: string;
  firstName: string;
  middleName: string;
  lastName: string;
  userId: string;
  email: string;
  contactNumber: string;
  age: number;
  gender: string;
  verified: boolean;
  createdAt: string;
}

const AdminUser: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'All' | 'Verified' | 'Unverified'>('All');
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [, setMessage] = useState<string | null>(null);

  //const backendURL = 'http://localhost:10000';

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const res = await fetch('/api/getnewsignup');
      if (!res.ok) throw new Error('Failed to fetch users');
      const data = await res.json();

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const mapped = data.users.map((u: any) => ({
        id: u._id,
        firstName: u.firstName,
        middleName: u.middleName,
        lastName: u.lastName,
        userId: u.userId,
        email: u.email,
        contactNumber: u.contactNumber,
        age: u.age,
        gender: u.gender,
        verified: u.verified,
        createdAt: new Date(u.createdAt).toLocaleDateString(),
      })).reverse(); 

      setUsers(mapped);
      setError(null);
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (err: unknown) {
      setError('Failed to load users.');
    }
    setLoading(false);
  };

  const verifyUser = async (id: string) => {
    try {
      const res = await fetch('/api/approve', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ _id: id }),
      });

      if (!res.ok) throw new Error('Verification failed.');

      setMessage('User verified successfully.');
      setSelectedUser(null);
      fetchUsers();
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (err) {
      setMessage('Failed to verify user.');
    }
  };

  const filteredUsers = users.filter((u) => {
    const matchesSearch =
      u.firstName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      u.lastName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      u.userId.toLowerCase().includes(searchQuery.toLowerCase()) ||
      u.email.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesStatus =
      statusFilter === 'All' ||
      (statusFilter === 'Verified' && u.verified) ||
      (statusFilter === 'Unverified' && !u.verified);

    return matchesSearch && matchesStatus;
  });

  return (
    <AdminRouteProtection>
      <div className="min-h-screen bg-gray-100 flex flex-col">
        {/* Header Section */}
        <header
          className="relative min-h-[300px] sm:h-[400px] bg-cover bg-center"
          style={{
            backgroundImage: "linear-gradient(rgba(13, 148, 136, 0.9), rgba(13, 148, 136, 0.8)), url(/app_bar.png)"
          }}
        >
          <div className="container mx-auto px-4 sm:px-8">
            <div className="flex flex-col sm:flex-row justify-between items-center py-6"></div>
            <div className="flex flex-col sm:flex-row items-center gap-4 text-center sm:text-left">
              <div className="relative w-24 h-24 sm:w-32 sm:h-32 rounded-xl border-4 border-white shadow-2xl overflow-hidden">
                <Image
                  src="/logo.png"
                  alt="Logo"
                  fill
                  sizes="(max-width: 640px) 96px, 128px"
                  style={{ objectFit: 'cover' }}
                  priority
                />
              </div>
              <div className="mt-4 sm:mt-0 sm:ml-4">
                <div className="mt-4 sm:mt-0 sm:ml-4">
                  <h1 className="text-3xl sm:text-5xl font-bold text-white tracking-wide">
                    User Management
                  </h1>
                  <p className="text-xl sm:text-2xl text-teal-100 mt-2">
                    Manage and verify users efficiently
                  </p>

                </div>
              </div>
            </div>
          </div>
        </header>

        {/* Main Content */}
        <main className="relative -mt-20 sm:-mt-32 z-10 container mx-auto px-4 sm:px-8 flex-grow pb-16">
          <div className="bg-white rounded-2xl shadow-xl p-4 sm:p-6">
            {/* Filter Controls */}
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6">
              <div className="flex flex-wrap gap-4 w-full">
                <div className="flex items-center gap-2 flex-1">
                  <FaFilter className="text-teal-600" />
                  <input
                    type="text"
                    placeholder="Search users..."
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="border rounded-md px-3 py-2 text-sm bg-white w-full"
                  />
                </div>
                <div className="flex items-center gap-2">
                  <FaFilter className="text-teal-600" />
                  <select
                    onChange={(e) => setStatusFilter(e.target.value as 'All' | 'Verified' | 'Unverified')}
                    className="border rounded-md px-3 py-2 text-sm bg-white"
                  >
                    <option value="All">All Status</option>
                    <option value="Verified">Verified</option>
                    <option value="Unverified">Unverified</option>
                  </select>
                </div>
                <button
                  onClick={fetchUsers}
                  className="bg-teal-600 hover:bg-teal-700 text-white px-4 py-2 rounded-md flex items-center gap-2"
                >
                  <FaSync />
                  <span>Refresh</span>
                </button>
              </div>
            </div>

            {/* Users Grid */}
            {loading ? (
              <div className="flex justify-center items-center h-64">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-teal-700"></div>
              </div>
            ) : error ? (
              <div className="bg-red-50 text-red-600 p-4 rounded-lg text-center">
                {error}
              </div>
            ) : (
              <div className="grid gap-4 grid-cols-1 md:grid-cols-2 xl:grid-cols-3">
                {filteredUsers.map((user, index) => (
                  <div key={user.id} className="bg-white border border-gray-200 rounded-lg shadow-sm hover:shadow-md transition-shadow">
                    <div className="p-4">
                      <div className="flex items-center justify-between mb-3">
                        <span className="bg-teal-100 text-teal-800 text-xs font-medium px-2.5 py-0.5 rounded-full">
                          #{index + 1}
                        </span>
                        <span className={`text-xs font-medium px-2.5 py-0.5 rounded-full ${user.verified ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'
                          }`}>
                          {user.verified ? 'Verified' : 'Unverified'}
                        </span>
                      </div>

                      <div className="mb-4">
                        <h3 className="text-lg font-semibold text-gray-900 mb-1">
                          {`${user.firstName} ${user.lastName}`}
                        </h3>
                        <div className="space-y-1">
                          <p className="text-sm text-gray-600">{user.email}</p>
                          <p className="text-sm text-gray-600">ID: {user.userId}</p>
                        </div>
                      </div>

                      <div className="flex gap-2 pt-3 border-t">
                        <button
                          onClick={() => setSelectedUser(user)}
                          className="flex-1 flex items-center justify-center px-3 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors"
                        >
                          <FaEye className="mr-2" />
                          View Details
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </main>

        {/* Add Footer at the bottom */}
        <div className="mt-auto">
          <Footer />
        </div>

        {/* User Details Modal */}
        {selectedUser && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-lg shadow-xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
              <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex justify-between items-center">
                <h2 className="text-xl font-semibold text-teal-800">
                  User Details
                </h2>
                <button
                  onClick={() => setSelectedUser(null)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <FaTimes />
                </button>
              </div>

              <div className="p-6 space-y-4">
                <div className="grid gap-4 sm:grid-cols-2">
                  <DetailItem label="User ID" value={selectedUser.userId || 'Not specified'} />
                  <DetailItem 
                    label="Full Name" 
                    value={`${selectedUser.firstName || ''} ${selectedUser.middleName || ''} ${selectedUser.lastName || ''}`.trim() || 'Not specified'} 
                  />
                  <DetailItem label="Email" value={selectedUser.email || 'Not specified'} />
                  <DetailItem label="Contact" value={selectedUser.contactNumber || 'Not specified'} />
                  <DetailItem label="Age" value={selectedUser.age?.toString() || 'Not specified'} />
                  <DetailItem label="Gender" value={selectedUser.gender || 'Not specified'} />
                  <DetailItem label="Status" value={selectedUser.verified ? 'Verified' : 'Unverified'} />
                  <DetailItem label="Joined Date" value={selectedUser.createdAt || 'Not specified'} />
                </div>

                {!selectedUser.verified && (
                  <div className="mt-6 pt-4 border-t border-gray-200 flex justify-end">
                    <button
                      onClick={() => verifyUser(selectedUser.id)}
                      className="bg-teal-600 hover:bg-teal-700 text-white px-4 py-2 rounded-md flex items-center gap-2"
                    >
                      <FaCheck />
                      Verify User
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </AdminRouteProtection>
  );
};

// Helper component for detail items
const DetailItem = ({ label, value }: { label: string; value: string }) => (
  <div>
    <dt className="text-sm font-medium text-gray-500">{label}</dt>
    <dd className="mt-1 text-sm text-gray-900">{value}</dd>
  </div>
);

export default AdminUser;
