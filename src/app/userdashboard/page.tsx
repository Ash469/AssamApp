"use client";
// import { useState } from 'react';
import NavBar from '../components/nav_bar'
import { FaPlusCircle, FaClock, FaFileAlt } from 'react-icons/fa'
import Link from 'next/link'
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Footer from '../components/footer';
// import Spline from '@splinetool/react-spline/next'

export default function Dashboard() {
  // const [isLoading, setIsLoading] = useState(true);
  const router = useRouter();
  
  useEffect(() => {
    // Check if the user is authenticated
    const token = localStorage.getItem('token');
    if (!token) {
      // Redirect to login page if no token exists
      router.push('/userlogin');
    }
  }, [router]);

  return (
    <div className="min-h-screen bg-white flex flex-col">
      <NavBar />

      <main className="flex-grow flex flex-col">
        <section className="relative h-[45vh] overflow-hidden">
          {/* Spline background */}
          <div className="absolute inset-0 w-full h-full">
            <div className="absolute inset-0 bg-green-500/30 z-[1]"></div>
            {/* {isLoading && (
              <div className="absolute inset-0 flex items-center justify-center bg-gray-100">
                <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-teal-500"></div>
              </div>
            )}
            <Spline 
              scene="https://prod.spline.design/Pogqf2P4pTEDp9b5/scene.splinecode"
              onLoad={() => setIsLoading(false)}
            /> */}
            
          </div>

          {/* Text content overlay */}
          <div className="relative z-10 h-full flex items-center justify-center">
            <div className="text-center max-w-2xl px-4 sm:px-6">
              <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold mb-2 sm:mb-4 text-black">
                Effortless Office Management at Your Fingertips!
              </h2>
              <p className="text-base sm:text-lg text-black/80">
                Take control of your daily tasks with ease. Our smart dashboard helps you manage applications, status, and notifications—all in one place.
              </p>
            </div>
          </div>
        </section>

        {/* Dashboard Cards */}
        <section className="bg-gray-100 py-10 px-6 md:px-16 flex-grow">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {/* Card 1 */}
            <div className="bg-white rounded-xl shadow-md p-6 relative overflow-hidden">
              <div className="grid grid-cols-12 gap-4">
                {/* Icon column */}
                <div className="col-span-4">
                  <div className="w-16 h-16 bg-teal-600 rounded-full flex items-center justify-center text-white border-2 border-teal-400">
                    <FaPlusCircle className="text-3xl" />
                  </div>
                </div>
                
                {/* Content column */}
                <div className="col-span-8">
                  <h3 className="text-lg font-semibold text-teal-800">New application</h3>
                  <p className="text-sm text-gray-600 mt-2">Add new application for services you need.</p>
                </div>
                
                {/* Button converted to Link */}
                <div className="col-span-12 flex justify-end mt-4">
                  <Link 
                    href="/application/new"
                    className="inline-block px-6 py-2 rounded-full bg-gray-200 hover:bg-gray-300 text-sm transition-colors"
                  >
                    Click to add
                  </Link>
                </div>
              </div>
            </div>

            {/* Card 2 */}
            <div className="bg-white rounded-xl shadow-md p-6 relative overflow-hidden">
              <div className="grid grid-cols-12 gap-4">
                {/* Icon column */}
                <div className="col-span-4">
                  <div className="w-16 h-16 bg-teal-600 rounded-full flex items-center justify-center text-white border-2 border-teal-400">
                    <FaClock className="text-3xl" />
                  </div>
                </div>
                
                {/* Content column */}
                <div className="col-span-8">
                  <h3 className="text-lg font-semibold text-teal-800">Application status</h3>
                  <p className="text-sm text-gray-600 mt-2">Check the status of your pending applications.</p>
                </div>
                
                {/* Button converted to Link */}
                <div className="col-span-12 flex justify-end mt-4">
                  <Link 
                    href="/application/status"
                    className="inline-block px-6 py-2 rounded-full bg-gray-200 hover:bg-gray-300 text-sm transition-colors"
                  >
                    Click to check
                  </Link>
                </div>
              </div>
            </div>

            {/* Card 3 */}
            <div className="bg-white rounded-xl shadow-md p-6 relative overflow-hidden">
              <div className="grid grid-cols-12 gap-4">
                {/* Icon column */}
                <div className="col-span-4">
                  <div className="w-16 h-16 bg-teal-600 rounded-full flex items-center justify-center text-white border-2 border-teal-400">
                    <FaFileAlt className="text-3xl" />
                  </div>
                </div>
                
                {/* Content column */}
                <div className="col-span-8">
                  <h3 className="text-lg font-semibold text-teal-800">Summary</h3>
                  <p className="text-sm text-gray-600 mt-2">View a summary of all your applications and their status.</p>
                </div>
                
                {/* Button converted to Link */}
                <div className="col-span-12 flex justify-end mt-4">
                  <Link 
                    href="/application/summary"
                    className="inline-block px-6 py-2 rounded-full bg-gray-200 hover:bg-gray-300 text-sm transition-colors"
                  >
                    Click to view
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>
      
      <Footer />
    </div>
  )
}
