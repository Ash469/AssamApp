"use client"
import { FaUser, FaBars, FaTimes } from 'react-icons/fa'
import Link from 'next/link'
import { useState } from 'react'

export default function NavBar() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)

  return (
    <nav className="relative bg-white border-b border-gray-300 p-2">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <h1 className="text-xl md:text-2xl font-bold text-teal-800">
            Assam Office
          </h1>

          {/* Desktop Menu */}
          <ul className="hidden md:flex items-center gap-6 text-gray-700 font-medium">
            <li><Link href="/userdashboard" className="hover:text-teal-600 transition-colors">Home</Link></li>
            <li><Link href="/about" className="hover:text-teal-600 transition-colors">About</Link></li>
            <li><Link href="/notifications" className="hover:text-teal-600 transition-colors">Notifications</Link></li>
            <li><Link href="/contact" className="hover:text-teal-600 transition-colors">Contact us</Link></li>
            <li><Link href="/faq" className="hover:text-teal-600 transition-colors">FAQ</Link></li>
          </ul>

          {/* Desktop Profile */}
          <Link href="/profile" className="hidden md:flex items-center gap-2 hover:text-teal-600 transition-colors">
            <FaUser className="text-xl" />
            <span className="text-sm font-semibold">Profile</span>
          </Link>

          {/* Mobile Menu Button */}
          <button 
            onClick={() => setIsMenuOpen(!isMenuOpen)}
            className="md:hidden p-2 rounded-md text-gray-700 hover:text-teal-600 focus:outline-none"
          >
            {isMenuOpen ? <FaTimes size={24} /> : <FaBars size={24} />}
          </button>
        </div>
      </div>

      {/* Mobile Menu */}
      <div className={`${isMenuOpen ? 'block' : 'hidden'} md:hidden absolute top-16 left-0 right-0 bg-white border-b border-gray-300 shadow-lg z-50`}>
        <div className="px-4 py-3 space-y-3">
          <ul className="space-y-3 text-gray-700">
            <li>
              <Link 
                href="/userdashboard" 
                className="block px-3 py-2 rounded-md hover:bg-teal-50 hover:text-teal-600"
                onClick={() => setIsMenuOpen(false)}
              >
                Home
              </Link>
            </li>
            <li>
              <Link 
                href="/about" 
                className="block px-3 py-2 rounded-md hover:bg-teal-50 hover:text-teal-600"
                onClick={() => setIsMenuOpen(false)}
              >
                About
              </Link>
            </li>
            <li>
              <Link 
                href="/notifications" 
                className="block px-3 py-2 rounded-md hover:bg-teal-50 hover:text-teal-600"
                onClick={() => setIsMenuOpen(false)}
              >
                Notifications
              </Link>
            </li>
            <li>
              <Link 
                href="/contact" 
                className="block px-3 py-2 rounded-md hover:bg-teal-50 hover:text-teal-600"
                onClick={() => setIsMenuOpen(false)}
              >
                Contact us
              </Link>
            </li>
            <li>
              <Link 
                href="/faq" 
                className="block px-3 py-2 rounded-md hover:bg-teal-50 hover:text-teal-600"
                onClick={() => setIsMenuOpen(false)}
              >
                FAQ
              </Link>
            </li>
          </ul>
          
          {/* Mobile Profile */}
          <Link 
            href="/profile" 
            className="flex items-center gap-2 px-3 py-2 rounded-md hover:bg-teal-50 hover:text-teal-600"
            onClick={() => setIsMenuOpen(false)}
          >
            <FaUser className="text-xl" />
            <span className="text-sm font-semibold">Profile</span>
          </Link>
        </div>
      </div>
    </nav>
  )
}