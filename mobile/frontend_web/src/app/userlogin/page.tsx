'use client';

import { FaUser, FaSignInAlt } from 'react-icons/fa';
import Link from 'next/link';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import jwt_decode from 'jwt-decode';

interface UserProfile {
  _id?: string;
  userId?: string;
  firstName?: string;
  middleName?: string;
  lastName?: string;
  email?: string;
  contactNumber?: string;
  gender?: string;
  age?: number;
  createdAt?: string;
  verified?: boolean;
}

export default function LoginPage() {
  const router = useRouter();
  const [loginMethod, setLoginMethod] = useState<'email' | 'phone'>('email');
  const [formData, setFormData] = useState({
    identifier: '',
    password: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  //const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:10000/api';

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const toggleLoginMethod = () => {
    setLoginMethod(prev => prev === 'email' ? 'phone' : 'email');
    setFormData({ ...formData, identifier: '' });
  };

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    fetch('/api/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formData),
    })
      .then(res => {
        if (!res.ok) {
          return res.json().then(data => {
            // Check specifically for 403 status
            if (res.status === 403) {
              throw new Error('Your account is pending verification. Please wait for admin approval.');
            }
            throw new Error(data.error || 'Something went wrong');
          });
        }
        return res.json();
      })
      .then(data => {
        console.log("Login successful:", data);
        localStorage.setItem('token', data.token);
        
        // Extract userId from JWT token exactly like profile page does
        let userId = null;
        try {
          const decoded = jwt_decode(data.token) as { 
            id?: string; 
            userId?: string; 
            _id?: string; 
            sub?: string 
          };
          userId = decoded.id || decoded.userId || decoded._id || decoded.sub;
          console.log("Extracted userId from token:", userId);
        } catch (decodeErr) {
          console.error('Error decoding token:', decodeErr);
        }
        
        // Use the same fetch approach as profile page
        return fetch('/api/getnewsignup')
          .then(response => {
            if (!response.ok) {
              throw new Error('Failed to fetch user profile');
            }
            return response.json();
          })
          .then(userData => {
            if (userData.users && userData.users.length > 0) {
              let userProfile = null;
              
              // Use exact same logic as profile page
              if (userId) {
                const loggedInUser = userData.users.find((user: UserProfile) => 
                  user._id === userId || user.userId === userId
                );
                
                if (loggedInUser) {
                  userProfile = loggedInUser;
                  console.log("Found logged in user:", loggedInUser);
                } else {
                  userProfile = userData.users[0];
                  console.warn('Logged in user not found in user list, showing first user');
                }
              } else {
                userProfile = userData.users[0];
              }
              
              // Store the exact same user profile that will be displayed in profile page
              if (userProfile) {
                localStorage.setItem('userProfile', JSON.stringify(userProfile));
                localStorage.setItem('userId', userProfile.userId || userProfile._id || '');
              }
            } else {
              throw new Error('No user data found');
            }
            
            // Add a small delay before navigation to ensure localStorage is updated
            setTimeout(() => {
              console.log("Navigating to dashboard...");
              router.push('/userdashboard');
            }, 100);
            
            // Force a hard navigation if the router.push doesn't work
            setTimeout(() => {
              console.log("Fallback navigation");
              window.location.href = '/userdashboard';
            }, 500);
          });
      })
      .catch(err => {
        console.error("Login error:", err);
        setError(err.message);
      })
      .finally(() => {
        setLoading(false);
      });
  };

  return (
    <div className="min-h-screen bg-gray-100">
      <header className="bg-teal-800 py-6 px-8 shadow-lg">
        <h1 className="text-5xl font-bold text-white text-center tracking-wide">
          User Login
        </h1>
      </header>

      <div className="container mx-auto px-4 py-8">
        <div className="max-w-md mx-auto bg-white rounded-xl shadow-2xl overflow-hidden">
          <div className="p-8">
            <div className="flex flex-col items-center mb-8">
              <FaUser className="text-6xl text-teal-600 mb-4" />
              <h2 className="text-3xl font-bold text-teal-700">
                User Access
              </h2>
              <p className="text-gray-600 mt-2 text-center">
                Please login with your credentials
              </p>
            </div>

            <div className="flex justify-center space-x-4 mb-6">
              <button
                type="button"
                onClick={toggleLoginMethod}
                className={`px-4 py-2 rounded-lg ${
                  loginMethod === 'email' 
                    ? 'bg-teal-600 text-white' 
                    : 'bg-gray-200 text-gray-700'
                }`}
              >
                Email
              </button>
              <button
                type="button"
                onClick={toggleLoginMethod}
                className={`px-4 py-2 rounded-lg ${
                  loginMethod === 'phone' 
                    ? 'bg-teal-600 text-white' 
                    : 'bg-gray-200 text-gray-700'
                }`}
              >
                Phone
              </button>
            </div>

            {error && (
              <div className="mb-4 p-3 bg-red-100 text-red-700 rounded-lg text-center">
                {error}
              </div>
            )}

            <form onSubmit={handleLogin} className="space-y-6">
              <div>
                <label htmlFor="identifier" className="block text-gray-700 mb-2 font-medium">
                  {loginMethod === 'email' ? 'Email Address' : 'Phone Number'}
                </label>
                <input
                  type={loginMethod === 'email' ? 'email' : 'tel'}
                  id="identifier"
                  name="identifier"
                  value={formData.identifier}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border-2 border-teal-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 transition-all bg-white text-gray-900 text-lg"
                  placeholder={loginMethod === 'email' ? 'Enter your email' : 'Enter your phone number'}
                  pattern={loginMethod === 'phone' ? '[0-9]{10}' : undefined}
                  required
                />
              </div>

              <div>
                <label htmlFor="password" className="block text-gray-700 mb-2 font-medium">
                  Password
                </label>
                <input
                  type="password"
                  id="password"
                  name="password"
                  value={formData.password}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border-2 border-teal-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 transition-all bg-white text-gray-900 text-lg"
                  placeholder="Enter your password"
                  required
                />
              </div>

              <button
                type="submit"
                disabled={loading}
                className={`w-full flex items-center justify-center p-3 ${
                  loading ? 'bg-teal-400' : 'bg-teal-600 hover:bg-teal-700'
                } text-white rounded-lg transition-colors`}
              >
                <FaSignInAlt className="text-xl mr-2" />
                <span className="text-lg font-semibold">
                  {loading ? 'Logging in...' : 'Login'}
                </span>
              </button>
            </form>

            <div className="mt-6 text-center space-y-3">
              {/* <div>
                <Link 
                  href="/forgot-password"
                  className="text-teal-600 hover:text-teal-800 transition-colors"
                >
                  Forgot Password?
                </Link>
              </div> */}
              <div>
                <Link 
                  href="/"
                  className="text-teal-600 hover:text-teal-800 transition-colors"
                >
                  Back to Home
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
