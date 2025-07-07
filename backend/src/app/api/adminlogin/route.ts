import { NextRequest, NextResponse } from "next/server";
import jwt from "jsonwebtoken";


export async function POST(req: NextRequest) {
  try {
    const { username, password } = await req.json(); // Correct way to parse JSON body

    if (!username || !password) {
      return NextResponse.json({ error: "Username and password are required" }, { status: 400 });
    }

    const adminUsername = process.env.ADMIN_USERNAME;
    const adminPassword = process.env.ADMIN_PASSWORD;
    const jwtSecret = process.env.JWT_SECRET;

    if (!adminUsername || !adminPassword || !jwtSecret) {
      return NextResponse.json({ error: "Server configuration error" }, { status: 500 });
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
    
    
    return NextResponse.json({ message: "Login successful",token }, { status: 200 });
  } catch (error) {
    return NextResponse.json({ error: "Internal server error "+error}, { status: 500 });
  }
}
