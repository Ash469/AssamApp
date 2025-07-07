import { NextRequest, NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import { connectDB } from "@/lib/db";
import User from "@/models/user";

// CORS Headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", // Change this to specific origin in production
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

// Handle OPTIONS for CORS
export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: corsHeaders });
}

// POST Request Handler
export async function POST(req: NextRequest) {
  await connectDB(); // Connect to MongoDB

  try {
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
    } = await req.json();

    // Validate required fields
    if (
      !firstName ||
      !lastName ||
      !contactNumber ||
      !email ||
      !userId ||
      !password||
      !gender||
      !age
    ) {
      return NextResponse.json(
        { error: "All required fields must be provided." },
        { status: 400 }
      );
    }

    // Ensure email and userId are unique
    const existingUser = await User.findOne({
      $or: [{ email }, { userId }],
    });
    if (existingUser) {
      return NextResponse.json(
        { error: "User with this email or userId already exists." },
        { status: 400 }
      );
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create new user
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

    return NextResponse.json(
      { message: "User created successfully" },
      { status: 201 }
    );
  } catch (error) {
    console.error("Signup error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
