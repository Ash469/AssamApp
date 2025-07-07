import mongoose, { Schema, Document, Model } from "mongoose";

interface IContact extends Document {
  fullName: string;
  email: string;
  contactNumber:string;
  message: string;
}

// Mongoose Schema
const ContactSchema = new Schema<IContact>(
  {
    fullName: { type: String, required: true },
    contactNumber:{type:String,required:true},
    email: { 
      type: String, 
      required: true, 
      validate: {
        validator: function (v: string) {
          return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v); 
        },
        message: "Invalid email format"
      }
    },
    message: { type: String, required: true },
  },
  { timestamps: true }
);

// Model
const Contact: Model<IContact> = mongoose.models.Contact || mongoose.model<IContact>("Contact", ContactSchema);

export default Contact;
