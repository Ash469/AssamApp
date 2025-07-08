import { NextResponse } from 'next/server';
import mongoose from 'mongoose';

// Check if MongoDB connection is established
const checkMongoDBConnection = async (): Promise<boolean> => {
    try {
        // Check if the connection is already established
        if (mongoose.connection.readyState === 1) {
            console.log('MongoDB connected to database:', mongoose.connection.db?.databaseName || 'unknown');
            return true;
        }

        
        if (!process.env.MONGODB_URI) {
            console.error('MongoDB connection string is missing');
            return false;
        }

        // Try to connect
        await mongoose.connect(process.env.MONGODB_URI);
        return true;
    } catch (error) {
        console.error('MongoDB connection error:', error);
        return false;
    }
};

export async function GET() {
    const isMongoConnected = await checkMongoDBConnection();

    return NextResponse.json({
        status: 'success',
        message: 'Server is running',
        mongodb: {
            connected: isMongoConnected,
            status: isMongoConnected ? 'connected' : 'disconnected'
        },
        timestamp: new Date().toISOString()
    });
}