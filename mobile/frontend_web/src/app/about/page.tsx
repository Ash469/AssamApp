import Footer from '../components/footer'
import NavBar from '../components/nav_bar'
import { FaBuilding, FaUsers, FaHeadset } from 'react-icons/fa'
// import Spline from '@splinetool/react-spline'

export default function About() {
  return (
    <div className="min-h-screen bg-white">
      {/* Navbar */}
      <NavBar />

      {/* Hero Section */}
      <section className="relative h-[300px] overflow-hidden">
        {/* Spline background */}
        <div className="absolute inset-0 w-full h-full">
          <div className="absolute inset-0 bg-green-500/30 z-[1]"></div>
          {/* <Spline 
            scene="https://prod.spline.design/Pogqf2P4pTEDp9b5/scene.splinecode" 
          /> */}
        </div>

        {/* Text content overlay */}
        <div className="relative z-10 h-full flex items-center justify-center">
          <div className="text-center max-w-2xl px-6">
            <h2 className="text-4xl font-bold mb-4 text-black">
              About Us
            </h2>
            <p className="text-lg text-black/80">
              Learn about our mission to streamline office management and bring efficiency to every workplace.
            </p>
          </div>
        </div>
      </section>

      {/* About Content */}
      <section className="py-10 px-6 md:px-16">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-2xl font-bold text-teal-800 mb-6">Our Story</h2>
          <p className="text-gray-700 mb-8 leading-relaxed">
            Founded in 2023, our office dashboard platform was created to address the challenges of modern workplace management. We recognized that organizations needed a centralized solution to handle applications, requests, and administrative tasks efficiently. Our team of dedicated developers and office management experts collaborated to build this intuitive platform that simplifies complex workflows and enhances productivity.
          </p>
          
          <h2 className="text-2xl font-bold text-teal-800 mb-6">Our Mission</h2>
          <p className="text-gray-700 mb-8 leading-relaxed">
            We are committed to transforming office management through technology. Our mission is to provide organizations with tools that reduce administrative burden, increase transparency, and improve employee satisfaction. We believe that when routine tasks are simplified, teams can focus on what truly matters.
          </p>
        </div>
      </section>

      {/* Feature Cards */}
      <section className="bg-gray-100 py-10 px-6 md:px-16">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-2xl font-bold text-teal-800 mb-8 text-center">What Sets Us Apart</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {/* Card 1 */}
            <div className="bg-white rounded-xl shadow-md p-6 hover:shadow-lg transition-shadow">
              <div className="flex flex-col items-center text-center">
                <div className="w-16 h-16 bg-teal-600 rounded-full flex items-center justify-center text-white mb-4">
                  <FaBuilding className="text-2xl" />
                </div>
                <h3 className="text-lg font-semibold text-teal-800 mb-2">Streamlined Workflows</h3>
                <p className="text-sm text-gray-600">
                  We simplify complex office processes into intuitive, user-friendly workflows.
                </p>
              </div>
            </div>

            {/* Card 2 */}
            <div className="bg-white rounded-xl shadow-md p-6 hover:shadow-lg transition-shadow">
              <div className="flex flex-col items-center text-center">
                <div className="w-16 h-16 bg-teal-600 rounded-full flex items-center justify-center text-white mb-4">
                  <FaUsers className="text-2xl" />
                </div>
                <h3 className="text-lg font-semibold text-teal-800 mb-2">User-Centered Design</h3>
                <p className="text-sm text-gray-600">
                  Our platform is designed with users in mind, ensuring a smooth and intuitive experience.
                </p>
              </div>
            </div>

            {/* Card 3 */}
            <div className="bg-white rounded-xl shadow-md p-6 hover:shadow-lg transition-shadow">
              <div className="flex flex-col items-center text-center">
                <div className="w-16 h-16 bg-teal-600 rounded-full flex items-center justify-center text-white mb-4">
                  <FaHeadset className="text-2xl" />
                </div>
                <h3 className="text-lg font-semibold text-teal-800 mb-2">Dedicated Support</h3>
                <p className="text-sm text-gray-600">
                  Our team is always ready to help you get the most out of our platform.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>
      <Footer />
    </div>
  )
}