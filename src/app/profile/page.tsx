"use client"
import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { FaUser, FaEnvelope, FaPhone, FaSignOutAlt } from 'react-icons/fa'
import jwt_decode from 'jwt-decode'
import NavBar from '../components/nav_bar'
import Footer from '../components/footer'

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

export default function ProfilePage() {
  const [userProfile, setUserProfile] = useState<UserProfile | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const router = useRouter()

  useEffect(() => {
    // Check if the user is authenticated
    const token = localStorage.getItem('token')
    if (!token) {
      // Redirect to login page if no token exists
      router.push('/userlogin')
      return
    }
    
    const fetchUserProfile = async () => {
      try {
        setLoading(true)
        
        const token = localStorage.getItem('token')
        
        if (!token) {
          throw new Error('No authentication token found')
        }
        
        let userId = null
        try {
          const decoded = jwt_decode(token) as { 
            id?: string; 
            userId?: string; 
            _id?: string; 
            sub?: string 
          }
          userId = decoded.id || decoded.userId || decoded._id || decoded.sub
        } catch (decodeErr) {
          console.error('Error decoding token:', decodeErr)
        }
        
        const response = await fetch('/api/getnewsignup')
        
        if (!response.ok) {
          throw new Error('Failed to fetch user profile')
        }
        
        const data = await response.json()
        
        if (data.users && data.users.length > 0) {
          if (userId) {
            const loggedInUser = data.users.find((user: UserProfile) => 
              user._id === userId || user.userId === userId
            )
            
            if (loggedInUser) {
              setUserProfile(loggedInUser)
            } else {
              setUserProfile(data.users[0])
              console.warn('Logged in user not found in user list, showing first user')
            }
          } else {
            setUserProfile(data.users[0])
          }
        } else {
          throw new Error('No user data found')
        }
      } catch (err: unknown) {
        console.error('Error fetching user profile:', err)
        setError(err instanceof Error ? err.message : 'An unknown error occurred')
      } finally {
        setLoading(false)
      }
    };
    
    fetchUserProfile();
  }, []);
  
  const handleLogout = () => {
    // Clear all data from localStorage, not just the token
    localStorage.clear()
    sessionStorage.clear()
    router.push('/')
  }

  const getFullName = (user: UserProfile | null) => {
    if (!user) return "";
    
    let name = user.firstName || "";
    if (user.middleName) name += " " + user.middleName;
    if (user.lastName) name += " " + user.lastName;
    
    return name.trim() || "N/A";
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-white flex flex-col">
        <NavBar />
        <div className="flex justify-center items-center flex-grow">
          <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-teal-500"></div>
        </div>
        <Footer />
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen bg-white flex flex-col">
        <NavBar />
        <div className="max-w-4xl mx-auto py-8 px-4 text-center flex-grow">
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
            <p>Error: {error}</p>
            <button 
              onClick={() => window.location.reload()} 
              className="mt-2 bg-red-100 hover:bg-red-200 text-red-800 font-bold py-2 px-4 rounded"
            >
              Retry
            </button>
          </div>
        </div>
        <Footer />
      </div>
    )
  }

  if (!userProfile) {
    return (
      <div className="min-h-screen bg-white flex flex-col">
        <NavBar />
        <div className="max-w-4xl mx-auto py-8 px-4 text-center flex-grow">
          <div className="bg-yellow-50 border border-yellow-200 text-yellow-700 px-4 py-3 rounded">
            <p>No user profile found</p>
          </div>
        </div>
        <Footer />
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-white flex flex-col">
      <NavBar />
      
      <main className="flex-grow bg-gray-100">
        <div className="max-w-4xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
          <div className="bg-white shadow-md rounded-lg overflow-hidden">
            <div className="bg-teal-700 text-white p-6">
              <div className="flex justify-between items-center">
                <h1 className="text-2xl font-bold">My Profile</h1>
                
                <button 
                  onClick={handleLogout}
                  className="flex items-center gap-2 bg-white text-red-600 px-4 py-2 rounded-md hover:bg-red-50 transition-colors"
                >
                  <FaSignOutAlt />
                  <span>Logout</span>
                </button>
              </div>
            </div>
            
            <div className="p-6">
              <div className="flex flex-col md:flex-row gap-6">
                <div className="flex flex-col items-center mb-6 md:mb-0">
                  <div className="bg-gray-200 rounded-full p-6 mb-4">
                    <FaUser size={80} className="text-gray-500" />
                  </div>
                  <h2 className="text-xl font-semibold text-gray-800">{getFullName(userProfile)}</h2>
                  <p className="text-gray-600">User ID: {userProfile?.userId || "N/A"}</p>
                </div>
                
                <div className="flex-1 space-y-4">
                  <h3 className="text-lg font-semibold border-b pb-2">Personal Information</h3>
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-3">
                      <div>
                        <p className="text-sm text-gray-500">Full Name</p>
                        <p className="font-medium flex items-center gap-2">
                          <FaUser className="text-teal-600" />
                          {getFullName(userProfile)}
                        </p>
                      </div>
                      
                      <div>
                        <p className="text-sm text-gray-500">Email Address</p>
                        <p className="font-medium flex items-center gap-2">
                          <FaEnvelope className="text-teal-600" />
                          {userProfile?.email || "Not provided"}
                        </p>
                      </div>
                      
                      <div>
                        <p className="text-sm text-gray-500">Contact Number</p>
                        <p className="font-medium flex items-center gap-2">
                          <FaPhone className="text-teal-600" />
                          {userProfile?.contactNumber || "Not provided"}
                        </p>
                      </div>
                    </div>
                    
                    <div className="space-y-3">
                      <div>
                        <p className="text-sm text-gray-500">Gender</p>
                        <p className="font-medium">
                          {userProfile?.gender || "Not specified"}
                        </p>
                      </div>
                      
                      <div>
                        <p className="text-sm text-gray-500">Age</p>
                        <p className="font-medium">{userProfile?.age || "Not specified"}</p>
                      </div>
                      
                      <div>
                        <p className="text-sm text-gray-500">User ID</p>
                        <p className="font-medium">{userProfile?.userId || userProfile?._id || "N/A"}</p>
                      </div>
                    </div>
                  </div>
                  
                  <div className="mt-6">
                    <p className="text-sm text-gray-500">Account Created</p>
                    <p className="font-medium">
                      {userProfile?.createdAt ? 
                        new Date(userProfile.createdAt).toLocaleDateString() : 
                        "Not available"}
                    </p>
                  </div>
                  
                  {userProfile?.verified !== undefined && (
                    <div className="mt-6 p-3 bg-gray-50 rounded-md">
                      <p className="text-sm font-medium">
                        Account Status: 
                        <span className={userProfile.verified ? "text-green-600 ml-2" : "text-yellow-600 ml-2"}>
                          {userProfile.verified ? "Verified" : "Not Verified"}
                        </span>
                      </p>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
      
      <Footer />
    </div>
  )
}
