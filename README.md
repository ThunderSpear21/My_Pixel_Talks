# Pixel Talks

A feature-rich chat application built with Flutter and Firebase

Pixel Talks is a real-time chat application that enables users to connect and communicate seamlessly. It comes with modern features like image sharing, push notifications, and a user-friendly interface.

## 🚀 Features
Real-Time Messaging: Chat with friends instantly using Firebase Firestore.

Image Sharing: Send and receive images with secure Cloudinary integration.

Push Notifications: Receive alerts for new messages and updates, even when the app is closed.

Secure Authentication: User authentication using Firebase Authentication.

Custom Notifications: Supports Android notification channels for categorized alerts.

Beautiful UI: A responsive and modern Flutter-based interface.

## 🛠️ Tech Stack
Frontend: Flutter

Backend: Firebase (Firestore, Authentication, Cloud Messaging)

Image Hosting: Cloudinary

## 📸 Screenshots


## 🔧 Setup and Installation
### Prerequisites
Install Flutter: Flutter Installation Guide

Set up Firebase for the project: Firebase Setup Guide

Create a Cloudinary account for image hosting: Cloudinary Signup

### Steps to Run the App
#### Clone this repository:

git clone https://github.com/ThunderSpear21/pixel-talks.git
cd pixel-talks

#### Install dependencies:

flutter pub get

#### Set up environment variables:
Create a .env file in the root directory.

Add your Cloudinary and Firebase credentials:

CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_PROJECT_ID=your_project_id

#### Run the app:

flutter run

## ✨ Key Highlights

### Image Handling:

Images are securely uploaded to Cloudinary, and only the public ID is stored for efficient management (uploading and deletion).


###  Push Notifications:
Notifications are powered by Firebase Cloud Messaging, with support for Android notification channels.



### Clean and Scalable Code:
The app is designed with clean architecture principles, making it easy to maintain and extend.



## 🙌 Acknowledgements
Flutter

Firebase

Cloudinary

Harsh H. Rajpurohit (YouTube Channel)
