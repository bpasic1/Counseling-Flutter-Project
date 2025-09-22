# Counseling-Flutter-Project
This project demonstrates the use of **Firebase Cloud Functions** to extend the functionality of a mobile application without relying on traditional server infrastructure. The app itself is a counseling platform where users can connect with selected experts, but its main purpose was to showcase how serverless architecture can support background tasks and improve security.

## Features
- **Serverless Backend** – No custom servers, only Firebase services.
- **Cloud Functions** for:
  - Sending email notifications automatically.
  - Processing expert requests and assigning roles.
  - Managing conversations and access rights securely.
  - Triggering actions on Firestore database changes.
- **Firestore Security Rules** – Fine-grained access control for users, experts, and admins.
- **Flutter Mobile App** – Frontend implementation for testing and demonstration.

## Technologies Used
- **Flutter** (Dart) – Mobile application
- **Firebase**:
  - Cloud Functions (Node.js runtime)
  - Firestore (NoSQL database)
  - Firebase Authentication
  - Firebase Cloud Messaging
- **Other Tools**: Git, VS Code, npm

## Key Learnings
- Cloud Functions are powerful for automating tasks such as notifications, email handling, and role management.
- Some features are better implemented on the client side (e.g., password reset with Firebase SDK).
- Serverless functions add security by running logic on the backend and preventing unauthorized access.
- Important to balance complexity: not every task requires a cloud function.

## Outcome
This project shows how **serverless architecture (FaaS)** can make mobile apps more scalable, secure, and easier to maintain by removing the need for custom backend servers. The implementation also highlights both the strengths and the limitations of relying on Firebase Cloud Functions in real-world scenarios.
