import admin from '../lib/firebase-admin';

interface PushNotificationData {
  title: string;
  content: string;
  [key: string]: string;
}

export const sendPushNotification = async (
  topic: string,
  title: string,
  body: string,
  data?: PushNotificationData
): Promise<boolean> => {
  try {
    if (!admin.apps.length) {
      console.error("Firebase Admin SDK not initialized");
      return false;
    }

    // Message payload
    const message = {
      notification: {
        title,
        body,
      },
      data: data || {},
      topic, // Send to a specific topic (all users subscribed to this topic will get the notification)
    };

    // Send the message
    const response = await admin.messaging().send(message);
    console.log('Push notification sent successfully:', response);
    return true;
  } catch (error) {
    console.error('Error sending push notification:', error);
    return false;
  }
};

export const subscribeToTopic = async (tokens: string[], topic: string): Promise<boolean> => {
  try {
    if (!admin.apps.length) {
      console.error("Firebase Admin SDK not initialized");
      return false;
    }

    // Subscribe the devices corresponding to the registration tokens to the topic
    const response = await admin.messaging().subscribeToTopic(tokens, topic);
    console.log('Successfully subscribed to topic:', response);
    return true;
  } catch (error) {
    console.error('Error subscribing to topic:', error);
    return false;
  }
};
