import { createApplication, getApplications, updateApplicationStatus, getApplicationsByUserId } from "@/controllers/applications_controller";
import { NextRequest, NextResponse } from "next/server";

// CORS Headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Allow-Credentials': 'true',
};

// OPTIONS handler for CORS preflight
export async function OPTIONS() {
  return NextResponse.json({}, {
    headers: corsHeaders,
  });
}

// POST request
export const POST = async (req: NextRequest) => {
  try {
    return await createApplication(req);
  } catch (error) {
    console.error("Error in applications POST route:", error);
    return NextResponse.json(
      { error: "API route error", details: (error as Error).message },
      { status: 500, headers: corsHeaders }
    );
  }
};

// GET request - now handles both all applications and user-specific applications
export const GET = async (req: NextRequest) => {
  const url = new URL(req.url);
  const userId = url.searchParams.get('userId');

  try {
    if (userId) {
      // If userId provided, get applications by this user
      return await getApplicationsByUserId(req);
    } else {
      // Otherwise get all applications
      return await getApplications(req);
    }
  } catch (error) {
    console.error("Error in applications GET route:", error);
    return NextResponse.json(
      { error: "API route error", details: (error as Error).message },
      { status: 500, headers: corsHeaders }
    );
  }
};

// PUT request for status update
export const PUT = async (req: NextRequest) => {
  try {
    return await updateApplicationStatus(req);
  } catch (error) {
    console.error("Error in applications PUT route:", error);
    return NextResponse.json(
      { error: "API route error", details: (error as Error).message },
      { status: 500, headers: corsHeaders }
    );
  }
};
