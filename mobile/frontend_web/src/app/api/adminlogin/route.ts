import { NextRequest, NextResponse } from "next/server";
import jwt from "jsonwebtoken";

// Add OPTIONS handler for CORS preflight requests
export async function OPTIONS() {
  return NextResponse.json({}, {
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  });
}

// Modify existing GET handler to include CORS headers
export async function GET() {
  try {
    return NextResponse.json({ 
      status: "Server is running",
      timestamp: new Date().toISOString()
    }, { 
      status: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      }
    });
  } catch (error) {
    return NextResponse.json({ 
      error: "Server error",
      details: error instanceof Error ? error.message : "Unknown error"
    }, { status: 500 });
  }
}

// Modify POST handler to include CORS headers
export async function POST(req: NextRequest) {
  try {
    const { username, password } = await req.json();

    if (!username || !password) {
      return NextResponse.json({ error: "Username and password are required" }, { status: 400 });
    }

    const adminUsername = process.env.ADMIN_USERNAME;
    const adminPassword = process.env.ADMIN_PASSWORD;
    const jwtSecret = process.env.JWT_SECRET;

    // Add debugging
    console.log('Environment variables:', {
      hasUsername: !!adminUsername,
      hasPassword: !!adminPassword,
      hasSecret: !!jwtSecret
    });

    if (!adminUsername || !adminPassword || !jwtSecret) {
      return NextResponse.json({ 
        error: "Server configuration error - Missing environment variables",
        missing: {
          username: !adminUsername,
          password: !adminPassword,
          secret: !jwtSecret
        }
      }, { status: 500 });
    }

    // Check admin username
    if (username != adminUsername) {
      return NextResponse.json({ error: "Invalid username" }, { status: 401 });
    }

    // Check password (if stored as hashed in .env)
    if (password!=adminPassword) {
      return NextResponse.json({ error: "Invalid password" }, { status: 401 });
    }

    // Generate JWT Token
    const token = jwt.sign({ role: "admin", username: adminUsername }, jwtSecret);
    
    
    return NextResponse.json({ message: "Login successful",token }, { 
      status: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      }
    });
  } catch (error) {
    return NextResponse.json({ error: "Internal server error "+error}, { 
      status: 500,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      }
    });
  }
}
