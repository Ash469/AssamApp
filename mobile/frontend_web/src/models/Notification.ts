import mongoose, { Schema, Document, models, Model } from 'mongoose';

export interface INotification extends Document {
  title: string;
  content: string;
  createdAt: Date;
  updatedAt: Date;
}

const NotificationSchema: Schema<INotification> = new Schema(
  {
    title: {
      type: String,
      required: [true, 'Title is required'],
      trim: true,
    },
    content: {
      type: String,
      required: [true, 'Content is required'],
      trim: true,
    },
  },
  {
    timestamps: true, // Automatically adds createdAt and updatedAt fields
  }
);

// Check if the model already exists before defining it
const Notification: Model<INotification> = models.Notification || mongoose.model<INotification>('Notification', NotificationSchema);

export default Notification;
