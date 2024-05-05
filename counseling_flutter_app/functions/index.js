const functions = require('firebase-functions');
const admin = require('firebase-admin');
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
