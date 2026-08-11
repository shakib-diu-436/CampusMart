CampusMart

CampusMart -- DIU Student Marketplace

A student-focused marketplace platform designed for DaffodilInternational University (DIU) students. CampusMart allows students tobuy products, sell products, and interact through a single account.

Overview

CampusMart is being developed as a cross-platform application usingFlutter. The same project can provide:

Android mobile application

Responsive Web application

Firebase-powered backend services

The platform is designed so that a user can be both a buyer and a sellerfrom the same account.

Core Account Model

CampusMart does not use separate buyer and seller accounts.

Each user has capability flags:

isBuyer: true/false
isSeller: true/false

New users can start as buyers:

isBuyer: true
isSeller: false

A buyer can later enable seller functionality without creating anotheraccount.

Main Features

Buyer

Browse products

Search and filter products

View product details

View seller information

Add products to cart

Place orders

Track orders

Manage profile

Seller

Become a seller from the existing account

Create product listings

Upload product images

Edit and delete listings

Manage inventory

View orders

Manage seller profile

Platform

Firebase Authentication

Cloud Firestore database

Cloud Storage for product/user images

Firebase Cloud Messaging for notifications

Firebase Hosting for the web application

Responsive Flutter Web interface

Technology Stack

Component              Technology

Mobile App             Flutter / DartWeb App                Flutter WebAuthentication         Firebase AuthenticationDatabase               Cloud FirestoreImage Storage          Firebase Cloud StorageNotifications          Firebase Cloud MessagingWeb Hosting            Firebase HostingAndroid Distribution   Google Play StoreDomain                 Custom domain such as campusmart.com

Architecture

                         CAMPUSMART
                              |
                +-------------+-------------+
                |                           |
          Android App                   Web App
            Flutter                   Flutter Web
                |                           |
                +-------------+-------------+
                              |
                         Firebase
                +-------------+-------------+
                |             |             |
              Auth        Firestore      Storage
                |             |             |
             Users        Products        Images
                         Orders
                         Reviews
                              |
                         Notifications
                              |
                            FCM

App + Website Deployment

The same Flutter project can generate both the Android application andweb application.

Android

flutter build appbundle

The generated Android App Bundle can be submitted to Google PlayConsole.

Web

flutter build web

Flutter generates the web build inside:

build/web/

That build can be deployed to Firebase Hosting.

Example flow:

Flutter Project
      |
      +---- flutter build appbundle
      |             |
      |          Play Store
      |             |
      |          Android App
      |
      +---- flutter build web
                    |
             Firebase Hosting
                    |
             campusmart.com
                    |
              Flutter Web

Firebase Data Structure

A possible Firestore structure:

users/
  userId/
    name
    email
    phone
    profileImageUrl
    isBuyer
    isSeller
    createdAt

products/
  productId/
    sellerId
    title
    description
    price
    category
    imageUrls
    stock
    createdAt
    updatedAt

orders/
  orderId/
    buyerId
    sellerId
    items
    totalAmount
    status
    createdAt

categories/
  categoryId/
    name
    imageUrl

Image Upload Flow

Customer/seller images should be stored in Firebase Cloud Storage ratherthan directly inside Firestore.

User selects image
       |
       v
Flutter App / Web
       |
       v
Firebase Cloud Storage
       |
       v
Download URL
       |
       v
Firestore product document

Firestore stores the image URL and product information, while CloudStorage stores the actual image files.

Firebase Production Plan

For production image uploads and other paid Firebase services, theproject may use the Firebase Blaze pay-as-you-go plan.

Blaze does not have a fixed monthly subscription fee. Charges depend onactual resource usage and applicable no-cost quotas.

Recommended production safeguards:

Enable billing alerts

Set a reasonable Google Cloud budget

Restrict Firebase Storage rules

Restrict Firestore security rules

Validate uploaded file types

Limit image sizes

Compress images before upload

Do not expose private user data

Recommended Project Structure

campus_mart/
|
+-- lib/
|   +-- models/
|   +-- services/
|   +-- screens/
|   +-- widgets/
|   +-- providers/
|   +-- utils/
|   +-- firebase_options.dart
|   +-- main.dart
|
+-- android/
+-- ios/
+-- web/
+-- assets/
+-- test/
+-- pubspec.yaml
+-- README.md

Development

Requirements

Flutter SDK

Dart SDK

Android Studio or VS Code

Firebase project

Firebase CLI

FlutterFire CLI

Install dependencies

flutter pub get

Run Android

flutter run

Run Web

flutter run -d chrome

Build Android

flutter build appbundle --release

Build Web

flutter build web --release

Firebase Setup

After creating a Firebase project:

firebase login

Then configure FlutterFire:

flutterfire configure

This generates the Firebase configuration required by the Flutterapplication.

Production Checklist

Before publishing CampusMart:

Configure Firebase Authentication

Configure Firestore security rules

Configure Cloud Storage security rules

Configure Firebase Cloud Messaging

Add image compression and upload limits

Add error handling

Add loading and empty states

Test Android release build

Test responsive web layout

Deploy Flutter Web to Firebase Hosting

Connect custom domain

Configure Play Console

Create privacy policy

Create terms and conditions

Configure Firebase/Google Cloud billing alerts

Perform security testing

Perform final production testing

Project Goal

CampusMart aims to provide a trusted, convenient, and campus-focusedmarketplace where DIU students can:

Buy products from fellow students

Sell their own products

Discover useful campus-related products and services

Manage buying and selling from one account

CampusMart -- Built for students, by students.
