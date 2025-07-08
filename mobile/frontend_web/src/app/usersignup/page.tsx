'use client'
import Link from 'next/link'
import { useState } from 'react'
import NavBar from '../components/nav_bar'

export default function UserSignup() {

  const [formData, setFormData] = useState({
    firstName: '',
    middleName: '',
    lastName: '',
    contactNumber: '',
    email: '',
    userId: '',
    age: '',
    gender: '',
    password: '',
    confirmPassword: ''
  })
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState('')
  const [isSuccess, setIsSuccess] = useState(false)

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    })
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!/^\d{10}$/.test(formData.contactNumber)) {
      setError('Contact number must be a valid 10-digit number')
      return
    }
    if (formData.password !== formData.confirmPassword) {
      setError('Passwords do not match')
      return
    }

    setIsLoading(true)
    setError('')

    try {
      const response = await fetch('/api/signup', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ...formData,
          age: parseInt(formData.age)
        }),
      })

      const data = await response.json()

      if (!response.ok) {
        if (data.field) {
          // Handle specific field errors
          if (data.field === 'email') {
            throw new Error('A user with this email already exists');
          } else if (data.field === 'userId') {
            throw new Error('This User ID is already taken');
          } else if (data.field === 'contactNumber') {
            throw new Error('This phone number is already registered');
          } else {
            throw new Error(data.error || 'Signup failed');
          }
        } else {
          throw new Error(data.error || 'Signup failed');
        }
      }

      setIsSuccess(true)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Something went wrong')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="h-screen flex flex-col bg-white overflow-hidden">
      <NavBar />

      {/* Main content area - calculate remaining height */}
      <div className="h-[calc(100vh-4rem)] grid grid-rows-2">
        {/* Top half with teal background */}
        <div className="bg-teal-800 relative" />

        {/* Bottom half with white background */}
        <div className="bg-white" />

        {/* Form Container - Adjusted positioning and responsiveness */}
        <div className="absolute inset-x-0 top-20 md:top-24 lg:top-28">
          <div className="max-w-6xl mx-auto px-4">
            <div className="bg-gray-200 p-4 md:p-6 lg:p-8 rounded-2xl shadow-lg">
              {/* Moved title here */}
              <h2 className="text-2xl lg:text-3xl font-bold text-teal-800 mb-6 text-center">
                New user Registration form
              </h2>

              {error && <p className="text-red-600 mb-4 text-sm md:text-base">{error}</p>}

              <form onSubmit={handleSubmit} className="grid grid-cols-1 lg:grid-cols-2 gap-4 lg:gap-6">
                {/* LEFT Column - Adjusted spacing */}
                <div className="space-y-3 lg:space-y-4">
                  {[
                    { label: 'First name', name: 'firstName', required: true },
                    { label: 'Middle name', name: 'middleName' },
                    { label: 'Last name', name: 'lastName', required: true },
                    { label: 'User ID', name: 'userId', required: true, placeholder: 'Eg: Rajesh2025A' },
                    { label: 'Password', name: 'password', required: true, type: 'password' }
                  ].map(({ label, name, required, placeholder, type = 'text' }) => (
                    <div key={name}>
                      <label className="block font-semibold text-black">
                        {label} {required && <span className="text-red-600">*</span>}
                      </label>
                      <input
                        type={type}
                        name={name}
                        value={formData[name as keyof typeof formData]}
                        onChange={handleChange}
                        placeholder={placeholder || `Enter your ${label.toLowerCase()}`}
                        required={required}
                        className="w-full px-4 py-2 border rounded-md focus:ring-2 focus:ring-teal-500"
                      />
                    </div>
                  ))}
                </div>

                {/* RIGHT Column - Adjusted spacing */}
                <div className="space-y-3 lg:space-y-4">
                  <div>
                    <label className="block font-semibold text-black">
                      Email ID <span className="text-red-600">*</span>
                    </label>
                    <input
                      type="email"
                      name="email"
                      value={formData.email}
                      onChange={handleChange}
                      placeholder="Enter your email"
                      required
                      className="w-full px-4 py-2 border rounded-md focus:ring-2 focus:ring-teal-500"
                    />
                  </div>

                  <div>
                    <label className="block font-semibold text-black">
                      Phone No. <span className="text-red-600">*</span>
                    </label>
                    <input
                      type="tel"
                      name="contactNumber"
                      value={formData.contactNumber}
                      onChange={handleChange}
                      placeholder="Enter your mobile number"
                      pattern="[0-9]{10}"
                      required
                      className="w-full px-4 py-2 border rounded-md focus:ring-2 focus:ring-teal-500"
                    />
                  </div>

                  <div>
                    <label className="block font-semibold text-black">
                      Gender <span className="text-red-600">*</span>
                    </label>
                    <select
                      name="gender"
                      value={formData.gender}
                      onChange={handleChange}
                      required
                      className="w-full px-4 py-2 border rounded-md focus:ring-2 focus:ring-teal-500"
                    >
                      <option value="">What&apos;s your gender?</option>
                      <option value="Male">Male</option>
                      <option value="Female">Female</option>
                      <option value="Other">Other</option>
                    </select>
                  </div>

                  <div>
                    <label className="block font-semibold text-black">
                      Age <span className="text-red-600">*</span>
                    </label>
                    <input
                      type="number"
                      name="age"
                      value={formData.age}
                      onChange={handleChange}
                      placeholder="Enter your age"
                      required
                      className="w-full px-4 py-2 border rounded-md focus:ring-2 focus:ring-teal-500"
                    />
                  </div>

                  <div>
                    <label className="block font-semibold text-black">
                      Confirm Password <span className="text-red-600">*</span>
                    </label>
                    <input
                      type="password"
                      name="confirmPassword"
                      value={formData.confirmPassword}
                      onChange={handleChange}
                      required
                      placeholder="Confirm your password"
                      className="w-full px-4 py-2 border rounded-md focus:ring-2 focus:ring-teal-500"
                    />
                  </div>
                </div>

                {/* Submit Button - Adjusted positioning */}
                <div className="col-span-1 lg:col-span-2 flex justify-center pt-4 lg:pt-6">
                  <button
                    type="submit"
                    disabled={isLoading}
                    className="px-6 py-2 bg-white text-black border-2 border-black rounded-full hover:bg-gray-100 text-sm md:text-base"
                  >
                    {isLoading ? 'Submitting...' : 'Submit'}
                  </button>
                </div>
              </form>

              {/* Login Link - Adjusted spacing */}
              <div className="mt-4 lg:mt-6 text-center text-sm md:text-base">
                <p className="text-gray-600">
                  Already have an account?{' '}
                  <Link 
                    href="/userlogin"
                    className="text-teal-600 hover:text-teal-800 transition-colors font-medium"
                  >
                    Login here
                  </Link>
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {isSuccess && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white p-8 rounded-2xl shadow-xl max-w-md w-full mx-4">
            <div className="text-center">
              <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg className="w-8 h-8 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7"></path>
                </svg>
              </div>
              <h3 className="text-2xl font-bold text-gray-900 mb-4">Registration Successful!</h3>
              <p className="text-gray-600 mb-6">
                Your account has been created and is pending admin verification. 
                You will be able to login once your account is approved.
              </p>
              <div className="space-y-3">
                <Link
                  href="/userlogin"
                  className="block w-full px-4 py-2 bg-teal-600 text-white rounded-lg hover:bg-teal-700 transition-colors"
                >
                  Go to Login Page
                </Link>
                <Link
                  href="/"
                  className="block w-full px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
                >
                  Return to Home
                </Link>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}