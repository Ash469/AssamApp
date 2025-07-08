import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import Application from "@/models/application_model";

// CORS Headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Allow-Credentials': 'true',
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
    console.log("Received application payload:", JSON.stringify(body));

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
      createdBy, // Added field for tracking who created the application
    } = body;

    // Log the extracted createdBy field
    console.log("Extracted createdBy:", createdBy);

    // Check each required field individually and log if missing
    const missingFields = [];
    if (!fullName) missingFields.push('fullName');
    if (!age) missingFields.push('age');
    if (!contactNumber) missingFields.push('contactNumber');
    if (!gender) missingFields.push('gender');
    if (!district) missingFields.push('district');
    if (!revenueCircle) missingFields.push('revenueCircle');
    if (!category) missingFields.push('category');
    if (!villageWard) missingFields.push('villageWard');
    if (!createdBy) missingFields.push('createdBy');

    if (missingFields.length > 0) {
      console.log("Missing required fields:", missingFields);
      return NextResponse.json(
        { 
          error: "Missing required fields", 
          missingFields: missingFields 
        },
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
      createdBy: createdBy.toString(), // Ensure createdBy is stored as string
    });

    return NextResponse.json(
      { message: "Application submitted successfully", data: newApplication },
      { status: 201, headers: corsHeaders }
    );
  } catch (error) {
    console.error("Application creation error:", error);
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

// Get Applications by UserId
export const getApplicationsByUserId = async (req: NextRequest): Promise<NextResponse> => {
  if (req.method === "OPTIONS") return handleOptionsRequest();

  try {
    await connectDB();

    // Get userId from query parameter
    const url = new URL(req.url);
    const userId = url.searchParams.get('userId');

    if (!userId) {
      return NextResponse.json(
        { error: "User ID is required" },
        { status: 400, headers: corsHeaders }
      );
    }

    const applications = await Application.find({ createdBy: userId });

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
