'use client'
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import NavBar from '../components/nav_bar';
import { FaChevronDown, FaChevronUp} from 'react-icons/fa';
import Footer from '../components/footer';
// import Spline from '@splinetool/react-spline';

export default function FAQPage() {
  // State to track which FAQ is open
  const [openFaq, setOpenFaq] = useState<number | null>(null);
  const router = useRouter();

  useEffect(() => {
    // Check if the user is authenticated
    const token = localStorage.getItem('token');
    if (!token) {
      // Redirect to login page if no token exists
      router.push('/userlogin');
    }
  }, [router]);

  // Toggle FAQ open/close
  const toggleFaq = (index: number) => {
    if (openFaq === index) {
      setOpenFaq(null);
    } else {
      setOpenFaq(index);
    }
  };

  // FAQ data
  const faqItems = [
    {
      question: "How do I submit a new application?",
      answer: "To submit a new application, navigate to the dashboard and click on the 'New application' card. Fill out the required information in the form and upload any necessary documents. Once completed, click the submit button and you will receive a confirmation message."
    },
    {
      question: "How can I check the status of my application?",
      answer: "You can check the status of your application by clicking on the 'Application status' card on the dashboard. This will show you a list of all your submitted applications along with their current status (Pending, Approved, or Rejected)."
    },
    {
      question: "What documents do I need to upload for my application?",
      answer: "Required documents vary depending on the type of application. Generally, you'll need identification proof (Aadhaar/PAN), address proof, and application-specific documents. The application form will clearly indicate which documents are required for your specific request."
    },
    {
      question: "How long does it take to process my application?",
      answer: "Processing times vary depending on the type of application and current workload. Most applications are processed within 7-14 working days. You can always check the current status of your application through the dashboard."
    },
    {
      question: "What should I do if my application is rejected?",
      answer: "If your application is rejected, you'll receive a notification with the reason for rejection. You can review the feedback, make necessary corrections, and resubmit your application. If you need assistance, please contact our support team."
    },
    {
      question: "Can I update information in my submitted application?",
      answer: "Once an application is submitted, you cannot directly edit it. However, if you need to make changes, you can contact support with your application ID and request for the specific changes to be made."
    },
    {
      question: "How do I download my application certificate after approval?",
      answer: "Once your application is approved, you can download your certificate by going to 'Application status', finding your approved application, and clicking on the 'Download' button next to it."
    }
  ];

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
              Frequently Asked Questions
            </h2>
            <p className="text-lg text-black/80">
              Find answers to common questions about our services
            </p>
          </div>
        </div>
      </section>

      {/* Content Section */}
      <section className="bg-gray-100 py-10 px-6 md:px-16 min-h-screen">
        <div className="max-w-3xl mx-auto">

          {/* FAQ Accordion */}
          <div className="space-y-4">
            {faqItems.map((faq, index) => (
              <div 
                key={index} 
                className="bg-white rounded-xl shadow-sm overflow-hidden"
              >
                <button
                  className="w-full px-6 py-4 flex justify-between items-center focus:outline-none"
                  onClick={() => toggleFaq(index)}
                >
                  <span className="font-medium text-left text-gray-800">{faq.question}</span>
                  {openFaq === index ? (
                    <FaChevronUp className="text-teal-600" />
                  ) : (
                    <FaChevronDown className="text-teal-600" />
                  )}
                </button>
                
                {openFaq === index && (
                  <div className="px-6 pb-4 text-gray-600 border-t border-gray-100 pt-3">
                    <p>{faq.answer}</p>
                  </div>
                )}
              </div>
            ))}
          </div>

          {/* Contact Section */}
          <div className="bg-gradient-to-r from-teal-50 to-cyan-50 rounded-lg shadow-sm p-5 mt-6 border border-teal-100 flex flex-col md:flex-row items-center justify-between">
            <div className="mb-3 md:mb-0">
              <h3 className="text-lg font-semibold text-teal-800 mb-1">
                Still have questions?
              </h3>
              <p className="text-gray-700 text-sm">
                Our support team is here to help with any questions.
              </p>
            </div>
            <div className="flex space-x-3">
              <a 
                href="mailto:support@example.com" 
                className="px-4 py-2 bg-teal-600 text-white rounded-md hover:bg-teal-700 transition text-sm font-medium flex items-center justify-center"
              >
                Email Us
              </a>
              <a 
                href="/contact" 
                className="px-4 py-2 bg-white border border-teal-600 text-teal-600 rounded-md hover:bg-teal-50 transition text-sm font-medium flex items-center justify-center"
              >
                Help Center
              </a>
            </div>
          </div>
        </div>
      </section>
      <Footer />
    </div>
  );
}