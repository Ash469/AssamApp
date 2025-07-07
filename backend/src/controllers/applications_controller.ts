import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import Application from "@/models/application_model";
import User from "@/models/user";

// CORS Headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", // Adjust in production
  "Access-Control-Allow-Methods": "GET, POST, PUT, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

// Handle CORS Preflight Requests
const handleOptionsRequest = () =>
  new NextResponse(null, { status: 204, headers: corsHeaders });

// Create Application
export const createApplication = async (req: NextRequest): Promise<NextResponse> => {
  if (req.method === "OPTIONS") return handleOptionsRequest();

  try {
    await connectDB();

    const body = await req.json();

    // Validate required fields
    const {
      fullName,
      age,
      contactNumber,
      gender,
      district,
      revenueCircle,
      category,
      villageWard,
      remarks,
      documentUrl,
      createdBy

    } = body;

    if (
      !fullName ||
      !age ||
      !contactNumber ||
      !gender ||
      !district ||
      !revenueCircle ||
      !category ||
      !villageWard||
      !createdBy
    ) {
      return NextResponse.json(
        { error: "Missing required fields" },
        { status: 400, headers: corsHeaders }
      );
    }

    // Create application
    const newApplication = await Application.create({
      fullName,
      age,
      contactNumber,
      gender,
      district,
      revenueCircle,
      category,
      villageWard,
      remarks,
      documentUrl,
      createdBy
 
    });

    return NextResponse.json(
      { message: "Application submitted successfully", data: newApplication },
      { status: 201, headers: corsHeaders }
    );
  } catch (error) {
    return NextResponse.json(
      { error: "Internal Server Error", details: (error as Error).message },
      { status: 500, headers: corsHeaders }
    );
  }
};

// Get All Applications
export const getApplications = async (req: NextRequest): Promise<NextResponse> => {
  if (req.method === "OPTIONS") return handleOptionsRequest();

  try {
    await connectDB();

    const applications = await Application.find();

    return NextResponse.json(
      { data: applications },
      { status: 200, headers: corsHeaders }
    );
  } catch (error) {
    return NextResponse.json(
      { error: "Internal Server Error", details: (error as Error).message },
      { status: 500, headers: corsHeaders }
    );
  }
};


// Get getApplicationsByUserId 
export const getApplicationsByUserId = async (req: NextRequest): Promise<NextResponse> => {
  if (req.method === "OPTIONS") return handleOptionsRequest();

  try {
    await connectDB();

        const body = await req.json();

    // Validate required fields
    const {
      createdBy
    } = body;

      if (!createdBy) {
      return NextResponse.json(
        { error: "'createdBy' is required in the request body." },
        { status: 400, headers: corsHeaders }
      );
    }

    const userfind=await User.findOne({userId:createdBy});

    if(userfind){
      const applications = await Application.find({createdBy});
       return NextResponse.json(
      { data: applications },
      { status: 200, headers: corsHeaders }
    );
    }

     return NextResponse.json(
      { message: "No user with given userId found" },
      { status: 404, headers: corsHeaders }
    );

   
  } catch (error) {
    return NextResponse.json(
      { error: "Internal Server Error", details: (error as Error).message },
      { status: 500, headers: corsHeaders }
    );
  }
};


// Update Application Status
export const updateApplicationStatus = async (req: NextRequest): Promise<NextResponse> => {
  if (req.method === "OPTIONS") return handleOptionsRequest();

  try {
    await connectDB();

    const { applicationId, status } = await req.json();

    if (!applicationId || !status) {
      return NextResponse.json(
        { error: "Application ID and status are required" },
        { status: 400, headers: corsHeaders }
      );
    }

    // Update status
    const updatedApplication = await Application.findByIdAndUpdate(
      applicationId,
      { status },
      { new: true }
    );

    if (!updatedApplication) {
      return NextResponse.json(
        { error: "Application not found" },
        { status: 404, headers: corsHeaders }
      );
    }

    return NextResponse.json(
      { message: "Status updated successfully", data: updatedApplication },
      { status: 200, headers: corsHeaders }
    );
  } catch (error) {
    return NextResponse.json(
      { error: "Internal Server Error", details: (error as Error).message },
      { status: 500, headers: corsHeaders }
    );
  }
};
