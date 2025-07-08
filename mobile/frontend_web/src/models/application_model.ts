import mongoose, { Schema, Document, Model } from "mongoose";

// Categories
const CATEGORY_OPTIONS = [
  "Administration",
  "Legal",
  "Business",
  "Others",
  "Education",
  "Finance",
  "Disaster Relief",
] as const;

const STATUS_OPTIONS = ["Pending", "Approved", "Rejected"] as const;

type CategoryType = (typeof CATEGORY_OPTIONS)[number];
type StatusType = (typeof STATUS_OPTIONS)[number];
type AreaType = "Village" | "Ward";
type GenderType = "Male" | "Female" | "Other";

interface IApplication extends Document {
  fullName: string;
  age: number;
  contactNumber: string;
  gender: GenderType;
  district: string;
  revenueCircle: string;
  category: CategoryType;
  villageWard: AreaType;
  remarks?: string;
  documentUrl?: string;
  status: StatusType;
  createdBy: string; // Added field to track who created the application
}

// Mongoose Schema
const ApplicationSchema = new Schema<IApplication>(
  {
    fullName: { type: String, required: true },
    age: { type: Number, required: true },
    contactNumber: {
      type: String,
      required: true,
      match: [/^\d{10}$/, "Invalid contact number format (must be 10 digits)"],
    },
    gender: { type: String, enum: ["Male", "Female", "Other"], required: true },
    district: { type: String, required: true },
    revenueCircle: { type: String, required: true },
    category: { type: String, required: true, enum: CATEGORY_OPTIONS },
    villageWard: { type: String, required: true, enum: ["Village", "Ward"] },
    remarks: { type: String },
    documentUrl: {
      type: String,
      validate: {
        validator: function (v: string) {
          return !v || /^(https?:\/\/.*\.(?:png|jpg|jpeg|pdf|docx?))$/i.test(v);
        },
        message: "Invalid document URL format",
      },
      default: "",
    },
    status: { type: String, enum: STATUS_OPTIONS, default: "Pending" },
    createdBy: { type: String, required: true }, // Store the userId who created this application
  },
  { timestamps: true }
);

// Model
const Application: Model<IApplication> =
  mongoose.models.Application || mongoose.model<IApplication>("Application", ApplicationSchema);

export default Application;
