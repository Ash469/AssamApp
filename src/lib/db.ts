import mongoose from "mongoose";
const MONGO_URI = process.env.MONGODB_URI || "mongodb+srv://Ayush:8002189162@app.7lk3p.mongodb.net/AssamAppIntern";


export const connectDB = async () => {
  if (mongoose.connection.readyState >= 1) return;
  await mongoose.connect(MONGO_URI);
  console.log("MongoDB connected");
};
