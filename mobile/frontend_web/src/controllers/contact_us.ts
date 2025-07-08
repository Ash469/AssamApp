import { NextRequest, NextResponse } from "next/server";
import Contact from "@/models/contact_us";
import { connectDB } from "@/lib/db";

// CORS Headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", 
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Access-Control-Allow-Credentials": "true",
};

// Create a new contact message (POST request)
export const createContact = async (req: NextRequest): Promise<NextResponse> => {
  try {
    // Handle CORS preflight request
    if (req.method === "OPTIONS") {
      return new NextResponse(null, { status: 204, headers: corsHeaders });
    }

    await connectDB();
    const { fullName, contactNumber, email, message } = await req.json();

    if (!fullName || !contactNumber || !email || !message) {
      return NextResponse.json(
        { error: "All fields are required" },
        { status: 400, headers: corsHeaders }
      );
    }

    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return NextResponse.json(
        { error: "Invalid email format" },
        { status: 400, headers: corsHeaders }
      );
    }

    const newContact = new Contact({ fullName, email, contactNumber, message });
    await newContact.save();

    return NextResponse.json(
      { success: true, message: "Message submitted successfully" },
      { status: 201, headers: corsHeaders }
    );
  } catch (error) {
    return NextResponse.json(
      { error: "Server error", details: error },
      { status: 500, headers: corsHeaders }
    );
  }
};

// Get all contact messages (GET request)
export const getContacts = async (): Promise<NextResponse> => {
  try {
    await connectDB();
    const contacts = await Contact.find().sort({ createdAt: -1 });

    return NextResponse.json(
      { success: true, contacts },
      { status: 200, headers: corsHeaders }
    );
  } catch (error) {
    return NextResponse.json(
      { error: "Server error", details: error },
      { status: 500, headers: corsHeaders }
    );
  }
};
