import { createApplication, getApplications, updateApplicationStatus } from "@/controllers/applications_controller";
import { NextRequest } from "next/server";

// POST request
export const POST = async (req: NextRequest) => {
  return await createApplication(req);
};

// GET request
export const GET = async (req: NextRequest) => { // Fix: Pass `req` to match controller signature
  return await getApplications(req);
};

// PUT request for status update
export const PUT = async (req: NextRequest) => {
  return await updateApplicationStatus(req);
};
