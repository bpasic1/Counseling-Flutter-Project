const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');
const axios = require('axios');
const { google } = require('googleapis');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const MESSAGING_SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';
const SCOPES = [MESSAGING_SCOPE];

exports.createUsername = functions.auth.user().onCreate(async (user) => {
  const uid = user.uid; // Get the user ID

  // Fetch additional user data from Firestore using the user ID
  const userSnapshot = await admin.firestore().collection('users').doc(uid).get();
  if (!userSnapshot.exists) {
    console.error('User document does not exist for UID:', uid);
    return null;
  }

  const userData = userSnapshot.data();
  const firstName = userData.firstName;
  const lastName = userData.lastName;

  // Generate username based on first and last name
  let username = firstName.toLowerCase() + lastName.toLowerCase() + 1;
  let usernameExists = true;
  let counter = 2;

  // Ensure username uniqueness
  while (usernameExists) {
    const usernameSnapshot = await admin.firestore().collection('users').where('username', '==', username).get();
    if (usernameSnapshot.empty) {
      usernameExists = false;
    } else {
      username = firstName.toLowerCase() + lastName.toLowerCase() + counter;
      counter++;
    }
  }

  // Update user document with the generated username
  await userSnapshot.ref.set({
    username: username
  }, { merge: true });

  console.log('Username added to user document:', username);
});



exports.changePassword = functions.https.onRequest(async (req, res) => {
    const { userId, newPassword } = req.body;
  
    try {
      await admin.auth().updateUser(userId, { password: newPassword });
      res.status(200).send('Password updated successfully');
    } catch (error) {
      console.error('Error updating password:', error);
      res.status(500).send('Error updating password');
    }
  });

const generateRandomPassword = () => {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let password = '';
    for (let i = 0; i < 16; i++) {
      password += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return password;
};

const SENDGRID_API_KEY = functions.config().sendgrid.key
  
sgMail.setApiKey(SENDGRID_API_KEY);

exports.forgotPassword = functions.https.onRequest(async (req, res) => {
    const { email } = req.body;
  
    try {
        // Generate a random password
        const newPassword = generateRandomPassword();
  
        // Send the new password to the user's email using SendGrid
        const msg = {
            to: email,
            from: {
                email: 'advicehaven23@gmail.com',
                name: 'Advice Haven Support', // Your verified sender's name
            },
            subject: 'Forgot Password - New Password',
            text: `Dear user,\n\nYour new password for the Advice Haven account is: ${newPassword}\n\nBest regards,\nAdvice Haven Support`,
            html: `
                <p>Dear user,</p>
                <p>Your new password for the Advice Haven account is: <strong>${newPassword}</strong></p>
                <p>Best regards,<br>Advice Haven Support</p>
            `,
        };
        await sgMail.send(msg);

        // Update the user's password in Firebase Authentication
        const userRecord = await admin.auth().getUserByEmail(email);
        await admin.auth().updateUser(userRecord.uid, {
            password: newPassword,
        });
  
        console.log('Password reset email sent and password updated successfully.');
  
        res.status(200).send('Password reset email sent and password updated successfully.');
    } catch (error) {
        console.error('Error resetting password:', error);
        res.status(500).send('Error resetting password.');
    }
});


const getAccessToken = () => {
    return new Promise(function(resolve, reject) {
      const jwtClient = new google.auth.JWT(
        serviceAccount.client_email,
        null,
        serviceAccount.private_key,
        SCOPES,
        null
      );
      jwtClient.authorize(function(err, tokens) {
        if (err) {
          reject(err);
          return;
        }
        resolve(tokens.access_token);
      });
    });
  };

  
  exports.sendExpertRequestNotification = functions.firestore
  .document('expertRequests/{requestId}')
  .onCreate(async (snap, context) => {
    const request = snap.data();

    // Fetch FCM tokens of administrators
    const adminUsers = await admin.firestore().collection('users').where('role', '==', 'administrator').get();
    const tokens = adminUsers.docs.map(doc => doc.data().fcmToken).filter(token => !!token);

    if (tokens.length > 0) {
      const payload = {
        message: {
          notification: {
            title: 'New Expert Request',
            body: 'A new request to become an expert has been submitted.',
          },
        }
      };

      try {
        const accessToken = await getAccessToken();
        for (const token of tokens) {
          payload.message.token = token;
          const response = await axios.post(
            'https://fcm.googleapis.com/v1/projects/bpasic1-firebase-msc/messages:send',
            { message: payload.message },
            {
              headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${accessToken}`,
              },
            }
          );
          console.log('Notification sent successfully:', response.data);
        }
      } catch (error) {
        console.error('Error sending notification:', error.response ? error.response.data : error.message);
      }
    } else {
      console.log('No administrator tokens found');
    }
  });

  

  exports.sendMessageNotification = functions.firestore
  .document('conversations/{conversationId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const messageData = snap.data();
    const conversationId = context.params.conversationId;

    // Fetch conversation details
    const conversationDoc = await admin.firestore().collection('conversations').doc(conversationId).get();
    if (!conversationDoc.exists) {
      console.log('Conversation does not exist:', conversationId);
      return;
    }

    const conversation = conversationDoc.data();
    const senderId = messageData.senderId;
    const recipientId = senderId === conversation.user_id ? conversation.expert_id : conversation.user_id;

    // Fetch recipient's FCM token
    const recipientDoc = await admin.firestore().collection('users').doc(recipientId).get();
    if (!recipientDoc.exists) {
      console.log('Recipient does not exist:', recipientId);
      return;
    }

    const recipientData = recipientDoc.data();
    const fcmToken = recipientData.fcmToken;

    if (!fcmToken) {
      console.log('Recipient does not have an FCM token:', recipientId);
      return;
    }

    const payload = {
      message: {
        token: fcmToken,
        notification: {
          title: 'New Message',
          body: messageData.message,
        },
      },
    };

    try {
      const accessToken = await getAccessToken();
      const response = await axios.post(
        `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
        { message: payload.message },
        {
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${accessToken}`,
          },
        }
      );
      console.log('Notification sent successfully:', response.data);
    } catch (error) {
      console.error('Error sending notification:', error.response ? error.response.data : error.message);
    }
  });


  exports.notifyUserOnRequestCancellation = functions.firestore
    .document('expertRequests/{requestId}')
    .onDelete(async (snap, context) => {
        const userId = snap.data().userId;
        const payload = {
            notification: {
                title: 'Request Canceled',
                body: 'Your request to become an expert has been canceled.',
            },
        };

        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        const token = userDoc.data().fcmToken;

        if (token) {
            await admin.messaging().sendToDevice(token, payload);
        }
    });