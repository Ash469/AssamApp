import { NextRequest, NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import { connectDB } from "@/lib/db";
import User from "@/models/user";

// CORS Headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", // Change this to specific origin in production
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json"
};

// Handle OPTIONS for CORS
export async function OPTIONS() {
  return new NextResponse(null, { 
    status: 204, 
    headers: corsHeaders 
  });
}

// POST Request Handler
export async function POST(req: NextRequest) {
  await connectDB();

  try {
    const body = await req.json();
    console.log('Received signup request:', body);

    // Add input validation logging
    Object.entries(body).forEach(([key, value]) => {
      console.log(`${key}:`, value);
    });

    const {
      firstName,
      middleName,
      lastName,
      contactNumber,
      email,
      userId,
      age,
      gender,
      password,
    } = body;

    // Enhanced validation
    const validationErrors = [];
    
    if (!firstName?.trim()) validationErrors.push('First name is required');
    if (!lastName?.trim()) validationErrors.push('Last name is required');
    if (!contactNumber?.trim()) validationErrors.push('Contact number is required');
    if (!/^\d{10}$/.test(contactNumber)) validationErrors.push('Contact number must be a valid 10-digit number');
    if (!email?.trim()) validationErrors.push('Email is required');
    if (!userId?.trim()) validationErrors.push('User ID is required');
    if (!password?.trim()) validationErrors.push('Password is required');
    if (!gender?.trim()) validationErrors.push('Gender is required');
    if (!age) validationErrors.push('Age is required');

    // Log validation result
    console.log('Validation check complete. Errors:', validationErrors.length > 0 ? validationErrors : 'None');

    if (validationErrors.length > 0) {
      return new NextResponse(
        JSON.stringify({ 
          error: "Validation failed", 
          details: validationErrors 
        }), 
        { 
          status: 400,
          headers: corsHeaders
        }
      );
    }

    // Check for existing user with detailed logging
    const existingUser = await User.findOne({
      $or: [{ email }, { userId }, { contactNumber }],
    });
    
    if (existingUser) {
      console.log('Existing user found:', existingUser.email);
      let field = 'userId';
      if (existingUser.email === email) {
        field = 'email';
      } else if (existingUser.contactNumber === contactNumber) {
        field = 'contactNumber';
      }
      
      return new NextResponse(
        JSON.stringify({ 
          error: `User with this ${field === 'contactNumber' ? 'phone number' : field} already exists.`,
          field: field
        }), 
        { 
          status: 400,
          headers: corsHeaders
        }
      );
    }

    // Hash password and create user
    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({
      firstName,
      middleName,
      lastName,
      contactNumber,
      email,
      userId,
      age,
      gender,
      password: hashedPassword,
    });

    await newUser.save();

    return new NextResponse(
      JSON.stringify({ message: "User created successfully" }), 
      { 
        status: 201,
        headers: corsHeaders
      }
    );

  } catch (error) {
    console.error("Signup error:", error);
    return new NextResponse(
      JSON.stringify({ error: "Internal server error" }), 
      { 
        status: 500,
        headers: corsHeaders
      }
    );
  }
}
