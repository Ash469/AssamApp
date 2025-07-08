import admin from 'firebase-admin';

let messagingInstance: admin.messaging.Messaging | null = null;

// Firebase Admin SDK initialization if not already initialized
if (!admin.apps.length) {
  try {
    // Get the Base64 string from the environment variable
    const serviceAccountBase64 = process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;

    if (!serviceAccountBase64) {
      console.error("FIREBASE_SERVICE_ACCOUNT_BASE64 environment variable not set!");
      throw new Error("FIREBASE_SERVICE_ACCOUNT_BASE64 environment variable not set!");
    }

    // Decode the Base64 string
    const serviceAccountJsonString = Buffer.from(serviceAccountBase64, 'base64').toString('utf-8');

    // Parse the JSON string
    const serviceAccount = JSON.parse(serviceAccountJsonString);

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount as admin.ServiceAccount)
    });

    console.log("Firebase Admin SDK initialized successfully from environment variable.");
    messagingInstance = admin.messaging();
    console.log("Firebase Messaging service obtained.");
  } catch (error) {
    console.error("Failed to initialize Firebase Admin SDK:", error);
  }
} else {
  // If already initialized, just get the messaging instance
  messagingInstance = admin.messaging();
  if (messagingInstance) {
    console.log("Firebase Messaging service obtained from existing app.");
  } else {
    console.error("Failed to obtain Firebase Messaging service from existing app.");
  }
}

export default admin;
export const messaging = messagingInstance;
