'use client';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import axios from 'axios';
import { FaEnvelope, FaUser, FaPhone, FaCommentAlt, FaPaperPlane } from 'react-icons/fa';
import NavBar from '../components/nav_bar';
import Footer from '../components/footer';
// import Spline from '@splinetool/react-spline';

const Contact = () => {
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    contactNumber: '',
    message: '',
  });

  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [submitted, setSubmitted] = useState(false);
  const router = useRouter();

  useEffect(() => {
    // Check if the user is authenticated
    const token = localStorage.getItem('token');
    if (!token) {
      // Redirect to login page if no token exists
      router.push('/userlogin');
    }
  }, [router]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const validate = () => {
    const { fullName, email, contactNumber, message } = formData;
    if (!fullName || !email || !contactNumber || !message) {
      setErrorMessage('All fields are required.');
      return false;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      setErrorMessage('Please enter a valid email.');
      return false;
    }

    if (!/^\d{10}$/.test(contactNumber)) {
      setErrorMessage('Please enter a valid 10-digit mobile number.');
      return false;
    }

    setErrorMessage(null);
    return true;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validate()) return;

    setIsLoading(true);
    try {
      const response = await axios.post('/api/contactUs', formData, {
        headers: {
          'Content-Type': 'application/json',
        },
        withCredentials: true,
      });
      if (response.status === 200 || response.status === 201) {
        setSubmitted(true);
        setFormData({ fullName: '', email: '', contactNumber: '', message: '' });
      } else {
        setErrorMessage('Failed to submit form. Please try again.');
      }
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (error) {
      setErrorMessage('Network error. Please check your connection.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex flex-col min-h-screen bg-gray-100">
      <NavBar />
      <section className="relative h-[200px] overflow-hidden">
        {/* Spline background */}
        <div className="absolute inset-0 w-full h-full">
          <div className="absolute inset-0 bg-green-500/30 z-[1]"></div>
          {/* <Spline 
            scene="https://prod.spline.design/Pogqf2P4pTEDp9b5/scene.splinecode" 
          /> */}
        </div>
        <div className="relative z-10 h-full flex items-center justify-center">
          <div className="text-center max-w-2xl px-6">
            <h2 className="text-3xl font-bold mb-2 text-black">Connect with Us</h2>
            <p className="text-base text-black/80">Have questions or feedback? We&apos;re here to help.</p>
          </div>
        </div>
      </section>

      <div className="max-w-6xl mx-auto px-4 py-8 flex-grow w-full">
        <div className="bg-white rounded-xl shadow-lg overflow-hidden">
          <div className="md:flex">
            <div className="bg-teal-700 text-white p-8 md:w-2/5">
              <h2 className="text-2xl font-bold mb-6">Contact Information</h2>
              
              <div className="space-y-5">
                <div className="flex items-start">
                  <FaEnvelope className="mt-1 mr-3 flex-shrink-0 text-base" />
                  <div>
                    <p className="font-medium">Email</p>
                    <p className="text-sm text-white/90">support@officemgmt.gov.in</p>
                  </div>
                </div>
                
                <div className="flex items-start">
                  <FaPhone className="mt-1 mr-3 flex-shrink-0 text-base" />
                  <div>
                    <p className="font-medium">Phone</p>
                    <p className="text-sm text-white/90">+91 1234567890</p>
                  </div>
                </div>
                
                <div className="flex items-start">
                  <FaUser className="mt-1 mr-3 flex-shrink-0 text-base" />
                  <div>
                    <p className="font-medium">Office Hours</p>
                    <p className="text-sm text-white/90">Monday - Friday: 9 AM - 5 PM</p>
                  </div>
                </div>
              </div>
            </div>
            <div className="p-8 md:w-3/5">
              {submitted && (
                <div className="bg-green-100 text-green-700 p-4 rounded-lg mb-5 flex items-center">
                  <div className="bg-green-200 rounded-full p-1 mr-3">
                    <svg className="w-5 h-5 text-green-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                  </div>
                  <p>Thank you for your message! We will get back to you soon.</p>
                </div>
              )}

              {errorMessage && (
                <div className="bg-red-100 text-red-700 p-4 rounded-lg mb-5 flex items-center">
                  <div className="bg-red-200 rounded-full p-1 mr-3">
                    <svg className="w-5 h-5 text-red-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </div>
                  <p>{errorMessage}</p>
                </div>
              )}

              <form onSubmit={handleSubmit} className="space-y-5">
                <div className="relative">
                  <div className="absolute left-3 top-1/2 -translate-y-1/2 text-teal-600">
                    <FaUser />
                  </div>
                  <input
                    type="text"
                    name="fullName"
                    placeholder="Full Name"
                    value={formData.fullName}
                    onChange={handleChange}
                    className="w-full p-3 pl-10 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500"
                  />
                </div>

                <div className="relative">
                  <div className="absolute left-3 top-1/2 -translate-y-1/2 text-teal-600">
                    <FaEnvelope />
                  </div>
                  <input
                    type="email"
                    name="email"
                    placeholder="Email"
                    value={formData.email}
                    onChange={handleChange}
                    className="w-full p-3 pl-10 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500"
                  />
                </div>

                <div className="relative">
                  <div className="absolute left-3 top-1/2 -translate-y-1/2 text-teal-600">
                    <FaPhone />
                  </div>
                  <input
                    type="tel"
                    name="contactNumber"
                    placeholder="Mobile Number"
                    value={formData.contactNumber}
                    onChange={handleChange}
                    maxLength={10}
                    className="w-full p-3 pl-10 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500"
                  />
                </div>

                <div className="relative">
                  <div className="absolute left-3 top-4 text-teal-600">
                    <FaCommentAlt />
                  </div>
                  <textarea
                    name="message"
                    placeholder="Message"
                    value={formData.message}
                    onChange={handleChange}
                    rows={4}
                    className="w-full p-3 pl-10 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500"
                  />
                </div>

                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full bg-teal-600 text-white py-3 px-6 rounded-lg hover:bg-teal-700 transition-colors flex items-center justify-center"
                >
                  {isLoading ? (
                    <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                  ) : (
                    <FaPaperPlane className="mr-2" />
                  )}
                  {isLoading ? 'Submitting...' : 'Send Message'}
                </button>
              </form>
            </div>
          </div>
        </div>
      </div>
      <Footer />
    </div>
  );
};

export default Contact;
