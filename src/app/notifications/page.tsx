'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import NavBar from '../components/nav_bar';
import Footer from '../components/footer';

interface NotificationItem {
  _id: string;
  title: string;
  content: string;
  createdAt: string;
  avatar?: string;
  hasAdv?: boolean;
}

function getAvatarColor(avatar: string): string {
  switch (avatar) {
    case 'D':
      return 'bg-teal-600 border-2 border-teal-400';
    case 'Y':
      return 'bg-teal-600 border-2 border-teal-400';
    case 'O':
      return 'bg-teal-600 border-2 border-teal-400';
    case 'ML':
      return 'bg-teal-600 border-2 border-teal-400';
    default:
      return 'bg-teal-600 border-2 border-teal-400';
  }
}

// Function to format date to a readable format
function formatDate(dateString: string): string {
  const date = new Date(dateString);
  return date.toLocaleDateString('en-GB', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  }).replace(/\//g, '-');
}

// Function to get first letter(s) for avatar
function getAvatarText(title: string): string {
  if (!title) return 'N';
  
  const words = title.split(' ');
  if (words.length > 1) {
    return (words[0][0] + words[1][0]).toUpperCase();
  }
  return title.substring(0, 1).toUpperCase();
}

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<NotificationItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedNotification, setSelectedNotification] = useState<NotificationItem | null>(null);
  const [showModal, setShowModal] = useState(false);
  const router = useRouter();

  const handleNotificationClick = (notification: NotificationItem) => {
    setSelectedNotification(notification);
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
    setSelectedNotification(null);
  };

  useEffect(() => {
    // Check if the user is authenticated
    const token = localStorage.getItem('token');
    if (!token) {
      // Redirect to login page if no token exists
      router.push('/userlogin');
    }
  }, [router]);

  useEffect(() => {
    const fetchNotifications = async () => {
      try {
        setLoading(true);
        const response = await fetch('/api/notification');
        
        if (!response.ok) {
          throw new Error('Failed to fetch notifications');
        }
        
        const data = await response.json();
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const formattedNotifications: NotificationItem[] = data.map((item: any) => ({
          _id: item._id,
          title: item.title,
          content: item.content,
          createdAt: item.createdAt,
          avatar: getAvatarText(item.title)
        }));
        
        setNotifications(formattedNotifications);
        setError(null);
      } catch (err) {
        console.error('Error fetching notifications:', err);
        setError('Failed to load notifications. Please try again.');
      } finally {
        setLoading(false);
      }
    };

    fetchNotifications();
  }, []);

  return (
    <div className="min-h-screen bg-white flex flex-col">
      <NavBar />
      <div className="flex-grow">
        <section className="relative h-[300px] overflow-hidden">
          {/* Spline background */}
          <div className="absolute inset-0 w-full h-full">
            <div className="absolute inset-0 bg-green-500/30 z-[1]"></div>
            {/* <Spline 
              scene="https://prod.spline.design/Pogqf2P4pTEDp9b5/scene.splinecode" 
            /> */}
          </div>
          <div className="relative z-10 h-full flex items-center justify-center">
            <div className="text-center max-w-2xl px-6">
              <h2 className="text-4xl font-bold mb-4 text-black">
                Stay Up to Date with Notifications
              </h2>
              <p className="text-lg text-black/80">
                Keep track of all important updates and messages in one centralized location.
                Never miss an important notification again!
              </p>
            </div>
          </div>
        </section>
        <section className="bg-gray-100 py-10 px-6 md:px-16">
          <div className="bg-white rounded-xl shadow-md overflow-hidden">
            <div className="p-4 border-b border-gray-100">
              <h3 className="text-lg font-semibold text-teal-800">Recent Notifications</h3>
            </div>
            
            {loading ? (
              <div className="text-center py-10">
                <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-teal-700"></div>
                <p className="mt-2 text-gray-600">Loading notifications...</p>
              </div>
            ) : error ? (
              <div className="text-center py-10 text-red-500">
                {error}
              </div>
            ) : notifications.length === 0 ? (
              <div className="text-center py-10 text-gray-600">
                No notifications available
              </div>
            ) : (
              <ul>
                {notifications.map((notification) => (
                  <li 
                    key={notification._id} 
                    className="border-b last:border-b-0 border-gray-100 hover:bg-gray-50 transition-colors cursor-pointer"
                    onClick={() => handleNotificationClick(notification)}
                  >
                    <div className="px-6 py-4 flex items-start">
                      <div className={`flex-shrink-0 w-12 h-12 ${getAvatarColor(notification.avatar || '')} rounded-full flex items-center justify-center text-white font-bold mr-4`}>
                        {notification.avatar}
                      </div>
                      
                      <div className="flex-1 min-w-0">
                        <p className="text-base font-semibold text-teal-800">{notification.title}</p>
                        <p className="text-sm text-gray-800 mt-0.5">{notification.content}</p>
                      </div>
                      
                      <div className="ml-3 flex flex-col items-end">
                        <span className="text-xs text-gray-500">{formatDate(notification.createdAt)}</span>
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </section>
      </div>

      {/* Notification Detail Modal */}
      {showModal && selectedNotification && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full mx-4 overflow-hidden">
            <div className="p-5 border-b border-gray-200">
              <div className="flex items-center justify-between">
                <h3 className="text-xl font-semibold text-teal-800">{selectedNotification.title}</h3>
                <button 
                  onClick={closeModal}
                  className="text-gray-500 hover:text-gray-700 focus:outline-none"
                >
                  <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
              <p className="text-xs text-gray-500 mt-1">{formatDate(selectedNotification.createdAt)}</p>
            </div>
            
            <div className="p-5">
              <p className="text-gray-700 whitespace-pre-wrap">{selectedNotification.content}</p>
            </div>
            
            <div className="px-5 py-4 bg-gray-50 text-right">
              <button
                onClick={closeModal}
                className="px-4 py-2 bg-teal-600 text-white rounded-md hover:bg-teal-700 focus:outline-none focus:ring-2 focus:ring-teal-500"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
      <div className="mt-auto">
        <Footer />
      </div>
    </div>
  );
}