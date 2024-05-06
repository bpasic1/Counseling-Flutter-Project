const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');
admin.initializeApp();

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