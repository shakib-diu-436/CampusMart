# 🛍️ CampusMart DIU

### 🎓 A Student-Centric Marketplace & Service Platform for Daffodil International University

**CampusMart** is a student-focused digital marketplace designed for the **Daffodil International University (DIU)** community.

The platform allows students to **buy and sell products, offer services, find skilled students, and connect with tutors or learners** — all within a single campus-focused ecosystem.

---

## ✨ Features

### 🛒 Product Marketplace

* Browse products listed by DIU students
* Product categories
* Product images and descriptions
* Product details
* Add products to cart
* Quantity management
* Checkout and order placement
* Seller information
* Order status tracking

### 💼 Student Services Marketplace

Students can turn their skills into services and offer them to other students.

Examples:

* 💻 Programming & Development
* 🎨 Graphic Design
* 📹 Video Editing
* 📸 Photography
* 📝 Content Writing
* 📊 Data Entry
* 📱 Social Media Management
* 🎤 Event Services
* And more

Students can:

* Create service listings
* Set pricing
* Describe their skills
* Receive service requests
* Connect with potential clients

### 📚 Tuition Marketplace

CampusMart also connects students who need academic support with students who can provide tutoring.

Students can:

* Offer tuition
* Find tuition opportunities
* Browse subjects
* Set preferred teaching locations
* Specify class level
* Set expected fees
* Apply/book tuition opportunities

### 🛍️ Cart & Orders

* Add products to cart
* Manage quantities
* View subtotal
* Delivery fee calculation
* Place orders
* Order status
* Payment status
* Seller-based order management

### 👤 Student Profile

* Student profile
* Personal information
* My products
* My services
* My tuition
* Orders
* Seller-related information

### 🔐 Authentication

* Firebase Authentication
* DIU email-based login
* Email verification
* Secure user sessions

### ☁️ Firebase Backend

CampusMart uses Firebase services for backend functionality, including:

* Firebase Authentication
* Cloud Firestore
* Firebase-based data management

---

## 🏗️ Application Architecture

```text
                    CampusMart
                        │
        ┌───────────────┼───────────────┐
        │               │               │
   Marketplace       Services         Tuition
        │               │               │
    Products        Skills/Jobs       Tutoring
        │               │               │
        └───────────────┼───────────────┘
                        │
                     Users
                        │
          ┌─────────────┼─────────────┐
          │             │             │
        Buyer         Seller        Student
          │             │             │
          └─────────────┼─────────────┘
                        │
                     Firebase
```

---

## 📱 Main Navigation

CampusMart uses a centralized navigation system:

```text
┌─────────────────────────────────────────────┐
│                                             │
│              Current Screen                 │
│                                             │
├─────────────────────────────────────────────┤
│ 🏠 Home │ 🛍 Market │ ➕ Sell │ 🛒 Cart │ 👤 Profile │
└─────────────────────────────────────────────┘
```

The main sections are:

* 🏠 Home
* 🛍️ Market
* ➕ Sell
* 🛒 Cart
* 👤 Profile

---

## 🧰 Technology Stack

| Technology                   | Purpose                           |
| ---------------------------- | --------------------------------- |
| **Flutter**                  | Cross-platform mobile application |
| **Dart**                     | Application programming language  |
| **Firebase Authentication**  | User authentication               |
| **Cloud Firestore**          | Database                          |
| **Firebase Storage**         | Image/file storage                |
| **Git & GitHub**             | Version control                   |
| **Android Studio / VS Code** | Development                       |

---

## 📂 Project Structure

```text
lib/
│
├── main.dart
├── main_navigation_screen.dart
│
├── home_screen.dart
├── marketplace_screen.dart
├── product_details_screen.dart
│
├── become_seller_screen.dart
├── cart_screen.dart
├── profile_screen.dart
│
├── service/
│   └── service-related screens
│
├── tuition/
│   └── tuition-related screens
│
└── firebase_options.dart
```

> Project structure may change as CampusMart continues to evolve.

---

## 🔥 Firestore Collections

The application uses Firestore to manage major application data.

```text
Firestore
│
├── users
│
├── products
│
├── services
│
├── tuition
│
├── orders
│
└── ...
```

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/shakib-diu-436/CampusMart.git
```

### 2. Open the project

```bash
cd CampusMart
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

Make sure your Firebase configuration is properly connected to the Flutter project.

### 5. Run the application

```bash
flutter run
```

---

## 📦 Build APK

### Debug APK

For testing:

```bash
flutter build apk --debug
```

Generated APK:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK

For production builds:

```bash
flutter build apk --release
```

### Android App Bundle

For Google Play Store:

```bash
flutter build appbundle --release
```

---

## 🧪 Current Development Status

CampusMart is currently under active development.

### Implemented

* [x] Firebase Authentication
* [x] DIU email verification
* [x] Product marketplace
* [x] Product details
* [x] Cart
* [x] Seller functionality
* [x] Orders
* [x] Services marketplace
* [x] Tuition marketplace
* [x] Student profile
* [x] Firebase database integration
* [x] Main application navigation

### In Development / Improvement

* [ ] Advanced service booking
* [ ] Advanced tuition booking
* [ ] Improved search and filtering
* [ ] Rating & review system
* [ ] Notifications
* [ ] Online payment integration
* [ ] Chat between buyers and sellers
* [ ] Production optimization
* [ ] Google Play Store release

---

## 🔐 Security

CampusMart is designed with student account security in mind.

Important configuration files and credentials should **never be committed to a public repository**.

Before pushing code:

```bash
git status
```

Review changed files and make sure no private keys, passwords, API secrets, or sensitive credentials are included.

---

## 🔄 Development Workflow

CampusMart follows a Git-based development workflow.

```text
Write Code
    ↓
Test Application
    ↓
Fix Bugs
    ↓
git add .
    ↓
git commit
    ↓
git push
    ↓
GitHub Backup
```

Example:

```bash
git add .
git commit -m "Update marketplace navigation"
git push
```

---

## 📌 Project Vision

CampusMart aims to create a **trusted digital ecosystem for university students** where students can:

> **Buy → Sell → Work → Teach → Learn**

Instead of using multiple external platforms, students can discover products, services, skills, and tuition opportunities within their own university community.

---

## 🎯 Future Vision

The long-term goal is to expand CampusMart into a complete university ecosystem featuring:

* 🛒 Student Marketplace
* 💼 Student Freelancing
* 📚 Tuition & Tutoring
* 💳 Digital Payments
* 💬 Student-to-Student Chat
* ⭐ Ratings & Reviews
* 🔔 Notifications
* 📍 Campus-based Discovery
* 🏫 University-specific Communities

---

## 👨‍💻 Developer

**Shakib**

Computer Science & Engineering
Daffodil International University

---

## 📄 License

This project is currently developed as an academic/personal project.

License and distribution terms may be updated in the future.

---

<p align="center">

### 🛍️ CampusMart DIU

**Buy • Sell • Work • Teach • Learn**

Made with ❤️ for the DIU student community.

</p>
