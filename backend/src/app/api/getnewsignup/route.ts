import {NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import User from "@/models/user";

export async function GET() {
  await connectDB(); // Connect to MongoDB

  try {
    // Fetch users where approve is false
    const pendingUsers = await User.find().select("-password").sort({ createdAt: 1 }); // Exclude password

    return NextResponse.json({ users: pendingUsers }, { status: 200 });
  } catch (error) {
    console.error("Error fetching users:", error);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
