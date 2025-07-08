'use client';

import React, { useState, useEffect } from 'react';
import { FaSync, FaTimes, FaTrash, FaBell } from 'react-icons/fa';
import Image from 'next/image';
import Footer from '@/app/components/footer';
import AdminRouteProtection from '@/app/components/AdminRouteProtection';

interface Notification {
  _id?: string;
  title: string;
  content: string;
  createdAt?: string;
  date?: string;
  active: boolean;
}

const AdminNotification: React.FC = () => {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [loadingNotifications, setLoadingNotifications] = useState(true);
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [confirmationData, setConfirmationData] = useState<{ index: number } | null>(null);
  const [actionResult, setActionResult] = useState<{ message: string; isError: boolean } | null>(null);
  const [selectedNotification, setSelectedNotification] = useState<Notification | null>(null);

  useEffect(() => {
    fetchNotifications();
  }, []);

  const fetchNotifications = async () => {
    try {
      setLoadingNotifications(true);
      const response = await fetch('/api/notification');
      if (!response.ok) {
        throw new Error('Failed to fetch notifications');
      }
      const data = await response.json();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const formattedNotifications = data.map((notification: any) => ({
        _id: notification._id,
        title: notification.title,
        content: notification.content,
        date: new Date(notification.createdAt).toISOString().split('T')[0],
        active: true, 
        createdAt: notification.createdAt
      }));
      
      setNotifications(formattedNotifications);
      setError('');
    } catch (error) {
      console.error('Error fetching notifications:', error);
      setError('Failed to load notifications. Please try again.');
    } finally {
      setLoadingNotifications(false);
    }
  };

  const addNotification = async () => {
    if (!title.trim() || !content.trim()) {
      setError('Please fill in all fields.');
      return;
    }

    setLoading(true);
    setError('');
    
    try {
      const response = await fetch('/api/notification', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ title, content }),
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Failed to create notification');
      }
      
      const data = await response.json();
      
      // Add the new notification to the state
      const newNotification: Notification = {
        _id: data.notification._id,
        title,
        content,
        date: new Date().toISOString().split('T')[0],
        active: true,
        createdAt: data.notification.createdAt
      };
      
      setNotifications([newNotification, ...notifications]);
      setTitle('');
      setContent('');
      setActionResult({
        message: 'Notification created successfully',
        isError: false
      });
    } catch (err) {
      console.error('Error creating notification:', err);
      setError(err instanceof Error ? err.message : 'Failed to create notification');
      setActionResult({
        message: err instanceof Error ? err.message : 'Failed to create notification',
        isError: true
      });
    } finally {
      setLoading(false);
    }
  };

  const toggleActive = (index: number) => {
    const updated = [...notifications];
    updated[index].active = !updated[index].active;
    setNotifications(updated);
  };

  const handleDeleteConfirmation = (index: number) => {
    setConfirmationData({ index });
    setShowConfirmation(true);
  };

  const deleteNotification = async (index: number) => {
    const notification = notifications[index];
    
    if (!notification._id) {
      setError('Cannot delete notification without ID');
      return;
    }
    
    try {
      const response = await fetch(`/api/notification?id=${notification._id}`, {
        method: 'DELETE',
      });
      
      if (!response.ok) {
        throw new Error(`Failed to delete notification: ${response.status} ${response.statusText}`);
      }
      
      const updated = [...notifications];
      updated.splice(index, 1);
      setNotifications(updated);
      setShowConfirmation(false);
      setActionResult({
        message: 'Notification deleted successfully',
        isError: false
      });
    } catch (err) {
      console.error('Error deleting notification:', err);
      setError(err instanceof Error ? err.message : 'Failed to delete notification');
      setActionResult({
        message: err instanceof Error ? err.message : 'Failed to delete notification',
        isError: true
      });
    }
  };

  return (
    <AdminRouteProtection>
      <div className="min-h-screen bg-gray-100 flex flex-col">
        {/* Header Section */}
        <header
          className="relative min-h-[250px] sm:h-[350px] bg-cover bg-center"
          style={{
            background: 'linear-gradient(rgba(13, 148, 136, 0.9), rgba(13, 148, 136, 0.8))',
          }}
        >
          <div className="container mx-auto px-4 sm:px-8">
            <div className="flex flex-col sm:flex-row justify-between items-center py-6"></div>
            <div className="flex flex-col sm:flex-row justify-between items-center gap-4 text-center sm:text-left">
              <div className="flex flex-col sm:flex-row items-center gap-4">
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
                  <h1 className="text-3xl sm:text-5xl font-bold text-white tracking-wide">Notification Management</h1>
                  <p className="text-xl sm:text-2xl text-teal-100 mt-2">Admin Dashboard</p>
                </div>
              </div>

              <button
                onClick={fetchNotifications}
                className="mt-6 sm:mt-0 bg-white/10 hover:bg-white/20 text-white px-6 sm:px-8 py-3 rounded-lg flex items-center gap-3 backdrop-blur-sm transition-all border-2 border-white/20 shadow-lg w-full sm:w-auto justify-center"
              >
                <FaSync className="text-xl sm:text-2xl" />
                <span className="text-base sm:text-lg font-semibold">Refresh</span>
              </button>
            </div>
          </div>
        </header>

        <main className="relative -mt-24 sm:-mt-40 z-10 container mx-auto px-4 sm:px-8 flex-grow pb-16">
          <div className="bg-white rounded-2xl shadow-xl p-4 sm:p-6 mb-8">
            <h2 className="text-xl font-bold text-teal-700 mb-6">Add New Notification</h2>
            <div className="space-y-4">
              <div>
                <input
                  type="text"
                  placeholder="Title"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="w-full p-3 border-2 border-teal-200 rounded-lg focus:border-teal-500 focus:outline-none transition-colors"
                />
              </div>
              <div>
                <textarea
                  placeholder="Content"
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  className="w-full p-3 border-2 border-teal-200 rounded-lg focus:border-teal-500 focus:outline-none transition-colors h-32"
                />
              </div>
              {error && <p className="text-red-500">{error}</p>}
              <button 
                onClick={addNotification}
                disabled={loading}
                className={`bg-teal-600 text-white px-6 py-3 rounded-lg hover:bg-teal-700 transition-colors font-semibold ${loading ? 'opacity-70 cursor-not-allowed' : ''}`}
              >
                {loading ? 'Adding...' : 'Add Notification'}
              </button>
            </div>
          </div>

          <div className="bg-white rounded-2xl shadow-xl p-4 sm:p-6">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-xl font-bold text-teal-700">Notifications List</h2>
            </div>
            
            {/* Notifications List */}
            {loadingNotifications ? (
              <div className="flex justify-center items-center h-64">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-teal-700"></div>
              </div>
            ) : notifications.length === 0 ? (
              <div className="text-center text-gray-500 py-12">No notifications available.</div>
            ) : (
              <div className="grid gap-4 grid-cols-1 md:grid-cols-2 xl:grid-cols-3">
                {notifications.map((notification, index) => (
                  <div
                    key={index}
                    className="bg-white border border-gray-200 rounded-lg shadow-sm hover:shadow-md transition-shadow"
                  >
                    <div className="p-4">
                      <div className="flex items-center justify-between mb-3">
                        <span className="bg-teal-100 text-teal-800 text-xs font-medium px-2.5 py-0.5 rounded-full">
                          #{index + 1}
                        </span>
                        <span
                          className={`text-xs font-medium px-2.5 py-0.5 rounded-full ${
                            notification.active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                          }`}
                        >
                          {notification.active ? 'Active' : 'Inactive'}
                        </span>
                      </div>

                      <div className="mb-4">
                        <h3 className="text-lg font-semibold text-gray-900 mb-1 truncate">{notification.title}</h3>
                        <p className="text-sm text-gray-600 line-clamp-3">{notification.content}</p>
                        <p className="text-xs text-gray-500 mt-2">Date: {notification.date}</p>
                      </div>

                      <div className="flex gap-1 sm:gap-2 pt-3 border-t">
                        <button
                          onClick={() => setSelectedNotification(notification)}
                          className="flex-1 flex items-center justify-center px-2 sm:px-3 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors text-xs sm:text-sm"
                        >
                          <FaBell className="mr-1 sm:mr-2" />
                          View
                        </button>
                        <button
                          onClick={() => toggleActive(index)}
                          className={`flex-1 flex items-center justify-center px-2 sm:px-3 py-2 rounded-md transition-colors text-xs sm:text-sm ${
                            notification.active 
                              ? 'bg-yellow-100 text-yellow-700 hover:bg-yellow-200'
                              : 'bg-green-100 text-green-700 hover:bg-green-200'
                          }`}
                        >
                          <FaSync className="mr-1 sm:mr-2" />
                          {notification.active ? 'Deactivate' : 'Activate'}
                        </button>
                        <button
                          onClick={() => handleDeleteConfirmation(index)}
                          className="flex-1 flex items-center justify-center px-2 sm:px-3 py-2 bg-red-100 text-red-700 rounded-md hover:bg-red-200 transition-colors text-xs sm:text-sm"
                        >
                          <FaTrash className="mr-1 sm:mr-2" />
                          Delete
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </main>

        <div className="mt-auto">
          <Footer />
        </div>

        {/* View Notification Modal */}
        {selectedNotification && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-lg shadow-xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
              <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex justify-between items-center">
                <h2 className="text-xl font-semibold text-teal-800">Notification Details</h2>
                <button
                  onClick={() => setSelectedNotification(null)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <span className="sr-only">Close</span>
                  <FaTimes />
                </button>
              </div>

              <div className="p-6 space-y-4">
                <div className="space-y-4">
                  <div>
                    <h3 className="font-semibold text-gray-900">Title</h3>
                    <p className="mt-1 text-gray-800">{selectedNotification.title}</p>
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900">Content</h3>
                    <p className="mt-1 text-gray-800 whitespace-pre-wrap">{selectedNotification.content}</p>
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900">Date</h3>
                    <p className="mt-1 text-gray-800">{selectedNotification.date}</p>
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900">Status</h3>
                    <p className="mt-1 text-gray-800">{selectedNotification.active ? 'Active' : 'Inactive'}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Confirmation Modal */}
        {showConfirmation && confirmationData && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-lg shadow-xl w-full max-w-md overflow-hidden">
              <div className="bg-gray-50 px-6 py-4 border-b border-gray-200">
                <h3 className="text-lg font-medium text-gray-900">Confirm Deletion</h3>
              </div>

              <div className="p-6">
                <p className="text-gray-700">
                  Are you sure you want to delete this notification? This action cannot be undone.
                </p>

                <div className="mt-6 flex justify-end space-x-3">
                  <button
                    onClick={() => setShowConfirmation(false)}
                    className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={() => deleteNotification(confirmationData.index)}
                    className="px-4 py-2 rounded-md text-sm font-medium text-white bg-red-600 hover:bg-red-700"
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Action Result Toast */}
        {actionResult && (
          <div className="fixed bottom-4 right-4 max-w-sm w-full">
            <div
              className={`rounded-lg shadow-lg p-4 ${
                actionResult.isError ? 'bg-red-50 border-l-4 border-red-600' : 'bg-green-50 border-l-4 border-green-600'
              }`}
            >
              <div className="flex justify-between">
                <p
                  className={`text-sm font-medium ${
                    actionResult.isError ? 'text-red-800' : 'text-green-800'
                  }`}
                >
                  {actionResult.message}
                </p>
                <button onClick={() => setActionResult(null)} className="text-gray-400 hover:text-gray-600">
                  <FaTimes />
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </AdminRouteProtection>
  );
};

export default AdminNotification;
