import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import User from "@/models/user";
import mongoose from "mongoose";

// Handle OPTIONS request for CORS preflight
export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'PATCH, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  });
}

export async function PATCH(req: NextRequest) {
  await connectDB();

  try {
    const { _id } = await req.json();

    if (!_id || !mongoose.Types.ObjectId.isValid(_id)) {
      return new NextResponse(
        JSON.stringify({ error: "Invalid user ID" }), 
        { 
          status: 400,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          }
        }
      );
    }

    const updatedUser = await User.findByIdAndUpdate(
      _id,
      { verified: true },
      { new: true, runValidators: true }
    ).select("-password");

    if (!updatedUser) {
      return new NextResponse(
        JSON.stringify({ error: "User not found" }), 
        { 
          status: 404,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          }
        }
      );
    }

    return new NextResponse(
      JSON.stringify({ message: "User approved successfully", user: updatedUser }), 
      { 
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        }
      }
    );
  } catch (error) {
    console.error("Error approving user:", error);
    return new NextResponse(
      JSON.stringify({ error: "Internal server error" }), 
      { 
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        }
      }
    );
  }
}
