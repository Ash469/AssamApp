'use client'

import { FaUserShield, FaSignInAlt } from 'react-icons/fa'
import Link from 'next/link'
import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'

export default function AdminLogin() {
  const router = useRouter()
  const [formData, setFormData] = useState({
    username: '',
    password: ''
  })
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState('')

  // Check if user is already logged in
  useEffect(() => {
    const userData = localStorage.getItem('userData');
    if (userData) {
      // User is already logged in, redirect to dashboard
      router.push('/admin/dashboard');
    }
  }, [router]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    })
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setError('')

    try {
      const response = await fetch('/api/adminlogin', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      })

      if (!response.ok) {
        throw new Error('Login failed')
      }

      // // Get the response data
      // const data = await response.json();
      
      // Save authentication state in localStorage
      const userData = {
        isAuthenticated: true,
        firstName: 'Admin', // You can update this with actual data from response
        username: formData.username
      };
      
      localStorage.setItem('userData', JSON.stringify(userData));
      
      // Redirect to dashboard after successful login
      router.push('/admin/dashboard')
    }finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-100">
      <header className="bg-teal-800 py-6 px-8 shadow-lg">
        <h1 className="text-5xl font-bold text-white text-center tracking-wide">
          Admin Login
        </h1>
      </header>

      <div className="container mx-auto px-4 py-8">
        <div className="max-w-md mx-auto bg-white rounded-xl shadow-2xl overflow-hidden">
          <div className="p-8">
            <div className="flex flex-col items-center mb-8">
              <FaUserShield className="text-6xl text-teal-600 mb-4" />
              <h2 className="text-3xl font-bold text-teal-700">
                Administrator Access
              </h2>
              <p className="text-gray-600 mt-2 text-center">
                Please login with your admin credentials
              </p>
            </div>
            
            {error && (
              <div className="mb-4 p-3 bg-red-100 text-red-700 rounded-lg text-center">
                {error}
              </div>
            )}
            
            <form onSubmit={handleSubmit} className="space-y-6">
              <div>
                <label htmlFor="username" className="block text-gray-700 mb-2 font-medium">
                  Username
                </label>
                <input
                  type="text"
                  id="username"
                  name="username"
                  value={formData.username}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border-2 border-teal-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 transition-all bg-white text-gray-900 text-lg"
                  placeholder="Enter admin username"
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
                  placeholder="Enter admin password"
                  required
                />
              </div>
              
              <button
                type="submit"
                disabled={isLoading}
                className={`w-full flex items-center justify-center p-3 ${
                  isLoading ? 'bg-teal-400' : 'bg-teal-600 hover:bg-teal-700'
                } text-white rounded-lg transition-colors`}
              >
                <FaSignInAlt className="text-xl mr-2" />
                <span className="text-lg font-semibold">
                  {isLoading ? 'Logging in...' : 'Login to Dashboard'}
                </span>
              </button>
            </form>

            <div className="mt-6 text-center">
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
  )
}