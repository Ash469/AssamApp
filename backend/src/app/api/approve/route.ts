import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import User from "@/models/user";
import mongoose from "mongoose";

export async function PATCH(req: NextRequest) {
  await connectDB(); // Connect to MongoDB

  try {
    const { _id } = await req.json(); // Get _id from request body

    // Validate _id
    if (!_id || !mongoose.Types.ObjectId.isValid(_id)) {
      return NextResponse.json({ error: "Invalid user ID" }, { status: 400 });
    }

    // Find and update the user
    const updatedUser = await User.findByIdAndUpdate(
      _id,
      { verified: true },
      { new: true, runValidators: true } // Return updated user and run validation
    ).select("-password"); // Exclude password

    if (!updatedUser) {
      return NextResponse.json({ error: "User not found" }, { status: 404 });
    }

    return NextResponse.json({ message: "User approved successfully", user: updatedUser }, { status: 200 });
  } catch (error) {
    console.error("Error approving user:", error);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
