import { NextRequest, NextResponse } from "next/server";
import { createContact, getContacts } from "@/controllers/contact_us";

// Get CORS headers based on request origin
const getCorsHeaders = (request: NextRequest) => {
  const origin = request.headers.get('origin') || '';
  
  return {
    "Access-Control-Allow-Origin": origin || "*", 
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Access-Control-Allow-Credentials": "true",
  };
};

// Handle OPTIONS preflight request
export async function OPTIONS(req: NextRequest) {
  console.log("OPTIONS request received for contactUs API", {
    url: req.url,
    method: req.method,
    headers: Object.fromEntries(req.headers)
  });
  
  return new NextResponse(null, {
    status: 204,
    headers: getCorsHeaders(req),
  });
}

// POST handler
export async function POST(req: NextRequest) {
  console.log("POST request received for contactUs API", {
    url: req.url,
    method: req.method,
    headers: Object.fromEntries(req.headers)
  });
  
  const response = await createContact(req);
  
  // Add CORS headers to the response
  Object.entries(getCorsHeaders(req)).forEach(([key, value]) => {
    response.headers.set(key, value);
  });
  
  return response;
}

// GET handler
export async function GET(req: NextRequest) {
  console.log("GET request received for contactUs API", {
    url: req.url,
    method: req.method,
    headers: Object.fromEntries(req.headers)
  });
  
  const response = await getContacts();
  
  // Add CORS headers to the response
  Object.entries(getCorsHeaders(req)).forEach(([key, value]) => {
    response.headers.set(key, value);
  });
  
  return response;
}
