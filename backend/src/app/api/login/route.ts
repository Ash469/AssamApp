import { NextRequest, NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { connectDB } from "@/lib/db";
import User from "@/models/user";

export async function POST(req: NextRequest) {
  await connectDB(); // Connect to MongoDB

  try {
    const { identifier, password } = await req.json(); // ✅ Use "identifier" for email or contactNumber

    // Validate required fields
    if (!identifier || !password) {
      return NextResponse.json(
        { error: "Email/Contact Number and password are required." },
        { status: 400 }
      );
    }

    // Check if user exists using email or contactNumber
    const user = await User.findOne({
      $or: [{ email: identifier }, { contactNumber: identifier }],
    });

    if (!user) {
      return NextResponse.json(
        { error: "User not found. Please sign up." },
        { status: 404 }
      );
    }

    // Check if user is verified
    if (!user.verified) {
      return NextResponse.json(
        { error: "User not verified. Please contact support." },
        { status: 403 }
      );
    }

    // Compare passwords
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return NextResponse.json(
        { error: "Invalid credentials." },
        { status: 401 }
      );
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user._id, email: user.email, contactNumber: user.contactNumber },
      process.env.JWT_SECRET as string,
      { expiresIn: "7d" }
    );

    // Send response
    return NextResponse.json(
      {
        message: "Login successful",
        token,
        user: {
          email: user.email,
          contactNumber: user.contactNumber,
          firstName: user.firstName,
          lastName: user.lastName,
        },
      },
      { status: 200 }
    );
  } catch (error) {
    console.error("Login error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
