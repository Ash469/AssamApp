'use client';

import Footer from '@/app/components/footer';
import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { FaUserShield, FaSignOutAlt, FaPhone, FaEnvelope } from 'react-icons/fa';
import AdminRouteProtection from '@/app/components/AdminRouteProtection';

export default function AdminProfilePage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  const handleLogout = () => {
    setLoading(true);
    localStorage.removeItem('userData');
    setTimeout(() => {
      router.push('/'); 
    }, 500);
  };

  return (
    <AdminRouteProtection>
      <div className="min-h-screen flex flex-col bg-gray-100">
        <header 
          className="relative min-h-[200px] bg-cover bg-center" 
          style={{ 
            backgroundImage: "linear-gradient(rgba(13, 148, 136, 0.9), rgba(13, 148, 136, 0.8)), url(/app_bar.png)"
          }}
        >
          <div className="container mx-auto px-4 py-8">
            <h1 className="text-4xl md:text-5xl font-bold text-white text-center tracking-wide">
              Admin Profile
            </h1>
          </div>
        </header>

        <main className="flex-grow relative -mt-20 z-10 container mx-auto px-4 pb-12">
          <div className="max-w-4xl mx-auto bg-white rounded-xl shadow-2xl overflow-hidden">
            <div className="flex flex-col md:flex-row">
              <div className="md:w-1/2 bg-teal-700 p-8 flex flex-col items-center justify-center">
                <div className="w-40 h-40 rounded-full bg-white/10 backdrop-blur-sm 
                                flex items-center justify-center text-white text-6xl 
                                border-4 border-white/30 shadow-2xl mb-6">
                  <FaUserShield />
                </div>
                <span className="px-4 py-2 bg-white/10 backdrop-blur-sm rounded-full 
                               text-white font-semibold mb-4 border border-white/20">
                  ADMINISTRATOR
                </span>
                <h2 className="text-3xl font-bold text-white mb-2">Admin User</h2>
                <p className="text-teal-100">@admin123</p>
              </div>
              <div className="md:w-1/2 p-8">
                <div className="space-y-6">
                  <h3 className="text-2xl font-bold text-teal-800 mb-6">
                    Profile Details
                  </h3>

                  <InfoItem 
                    icon={<FaUserShield />}
                    label="Full Name"
                    value="Admin User"
                  />
                  <Divider />
                  <InfoItem 
                    icon={<FaPhone />}
                    label="Phone Number"
                    value="+91 9801589162"
                  />
                  <Divider />
                  <InfoItem 
                    icon={<FaEnvelope />}
                    label="Email"
                    value="admin@assam.gov.in"
                  />

                  <button
                    onClick={handleLogout}
                    disabled={loading}
                    className={`w-full flex items-center justify-center p-4 mt-8
                              ${loading ? 'bg-teal-400' : 'bg-teal-600 hover:bg-teal-700'}
                              text-white rounded-lg transition-colors`}
                  >
                    <FaSignOutAlt className="text-xl mr-2" />
                    <span className="text-lg font-semibold">
                      {loading ? 'Logging out...' : 'Logout'}
                    </span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </main>
        <div className="mt-auto">
          <Footer />
        </div>
      </div>
    </AdminRouteProtection>
  );
}

function InfoItem({ icon, label, value }: { icon: React.ReactNode; label: string; value: string }) {
  return (
    <div className="flex items-center space-x-4">
      <div className="text-2xl text-teal-600">{icon}</div>
      <div>
        <div className="text-sm text-teal-600 font-medium">{label}</div>
        <div className="text-lg text-gray-800">{value}</div>
      </div>
    </div>
  );
}

function Divider() {
  return <hr className="border-t border-teal-100" />;
}
