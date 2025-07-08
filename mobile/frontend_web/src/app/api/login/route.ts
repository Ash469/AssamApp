import { NextRequest, NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { connectDB } from "@/lib/db";
import User from "@/models/user";

// Define CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Content-Type': 'application/json'
};

export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: corsHeaders
  });
}

export async function POST(req: NextRequest) {
  await connectDB();

  try {
    const { identifier, password } = await req.json();
    console.log('Login attempt for:', identifier);

    if (!identifier || !password) {
      return new NextResponse(
        JSON.stringify({ 
          status: "error",
          message: "Email/Contact Number and password are required." 
        }), 
        { 
          status: 400,
          headers: corsHeaders
        }
      );
    }

    const user = await User.findOne({
      $or: [{ email: identifier }, { contactNumber: identifier }],
    });

    if (!user) {
      return new NextResponse(
        JSON.stringify({ 
          status: "error",
          message: "User not found" 
        }), 
        { 
          status: 404,
          headers: corsHeaders
        }
      );
    }

    // Check if user is verified
    if (!user.verified) {
      return new NextResponse(
        JSON.stringify({ 
          status: "error",
          message: "Account not verified",
          details: "Please contact support for verification." 
        }), 
        { 
          status: 403,
          headers: corsHeaders
        }
      );
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return new NextResponse(
        JSON.stringify({ 
          status: "error",
          message: "Invalid credentials" 
        }), 
        { 
          status: 401,
          headers: corsHeaders
        }
      );
    }

    const token = jwt.sign(
      { userId: user._id, email: user.email },
      process.env.JWT_SECRET as string,
      { expiresIn: "7d" }
    );

    // Log successful login
    console.log(`User logged in successfully: ${user.email || user.contactNumber} (${user.firstName} ${user.lastName})`);

    return new NextResponse(
      JSON.stringify({
        status: "success",
        message: "Login successful",
        token,
        user: {
          email: user.email,
          contactNumber: user.contactNumber,
          firstName: user.firstName,
          lastName: user.lastName,
        },
      }), 
      { 
        status: 200,
        headers: corsHeaders
      }
    );

  } catch (error) {
    console.error("Login error:", error);
    return new NextResponse(
      JSON.stringify({ 
        status: "error",
        message: "Internal server error" 
      }), 
      { 
        status: 500,
        headers: corsHeaders
      }
    );
  }
}
