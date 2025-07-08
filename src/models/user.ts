import { Schema, model, models, Document } from "mongoose";

// TypeScript Interface for User
interface IUser extends Document {
  firstName: string;
  middleName?: string;
  lastName: string;
  contactNumber: string;
  email: string;
  userId: string;
  age?: number;
  gender?: "Male" | "Female" | "Other";
  password: string;
  verified: boolean;
}

// Schema Definition
const userSchema = new Schema<IUser>(
  {
    firstName: { type: String, required: true },
    middleName: { type: String },
    lastName: { type: String, required: true },
    contactNumber: { type: String, unique: true, sparse: true },
    email: { type: String, required: true, unique: true },
    userId: { type: String, required: true, unique: true },
    age: { type: Number },
    gender: { type: String, enum: ["Male", "Female", "Other"] },
    password: { type: String, required: true },
    verified: { type: Boolean, default: false },
  },
  { timestamps: true }
);

// Create or get existing model
const User = models.User || model<IUser>("User", userSchema);

export default User;
