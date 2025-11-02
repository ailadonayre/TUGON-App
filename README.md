<p align="center">
  <img src="assets/logo/TUGON_logo.png" alt="TUGON App Logo" width="120" />
</p>

<h1 align="center">
  <img src="assets/logo/TUGON_Logo-uppercase.png" alt="TUGON Text Logo" width="180" style="vertical-align: middle;"/><br>
  Centralized Barangay Assistance & Reporting Platform
</h1>

<p align="center">
  <b>Empowering communities through faster response, transparency, and digital governance.</b><br>
  Built with <b>Flutter</b> + <b>Firebase</b> for a smarter, more connected barangay system.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-v3.24-5A84F7?logo=flutter" alt="Flutter Badge" />
  <img src="https://img.shields.io/badge/Firebase-Enabled-FFB300?logo=firebase" alt="Firebase Badge" />
  <img src="https://img.shields.io/badge/License-MIT-FA485D" alt="License Badge" />
  <img src="https://img.shields.io/badge/Status-Active-brightgreen" alt="Status Badge" />
</p>

---

## 🎯 Overview

**TUGON** (meaning *“response”* in Filipino) is a proposed **centralized barangay service mobile application** that enables **residents and officials to connect, report incidents, and access community services seamlessly**.

It supports **multiple barangays** (e.g., Alangilan & Tinga Itaas) through **one shared system**, promoting:

- ⚡ **Efficiency** – faster processing of reports and requests
- 🔍 **Transparency** – clear visibility of services and response actions
- ⏱️ **Quick Response Times** – enabling authorities to act promptly on incidents

> 🧩 *TUGON embodies the spirit of unity, readiness, and digital empowerment for communities, ensuring every resident can be heard and helped quickly.*

---

## 🎯 Project Objectives

**Main Objective:**  
To develop a centralized digital platform for barangay-level incident reporting and assistance coordination.

**Specific Objectives:**
- Streamline barangay service requests and reports through verified user accounts.
- Provide real-time announcements, alerts, and events to residents.
- Enable digital verification for residency and documents.
- Support multi-barangay coordination and communication.

---

## 🌍 Sustainable Development Goals (SDGs) Supported

| SDG | Badge | Description |
| :-- | :---- | :----------- |
| 🏭 **SDG 9 – Industry, Innovation, and Infrastructure** | ![SDG 9](https://img.shields.io/badge/SDG9-Industry%20%26%20Innovation-5A84F7) | Fosters **innovation and digital infrastructure** by connecting multiple barangays for efficient service management. |
| ⚖️ **SDG 10 – Reduced Inequalities** | ![SDG 10](https://img.shields.io/badge/SDG10-Reduced%20Inequalities-FA485D) | Ensures **equal access to services** for all residents, reducing disparities in response times and assistance. |
| 🏙️ **SDG 11 – Sustainable Cities and Communities** | ![SDG 11](https://img.shields.io/badge/SDG11-Sustainable%20Cities-FFB300) | Enhances **transparency and coordination**, contributing to safer, more resilient communities. |
| 🕊️ **SDG 16 – Peace, Justice, and Strong Institutions** | ![SDG 16](https://img.shields.io/badge/SDG16-Peace%20%26%20Justice-101010) | Strengthens **local governance and accountability**, promoting trust and institutional transparency. |

---

## 🗓️ Project Timeline

| Month | Milestone |
| :---- | :--------- |
| **September 2025** | Project ideation and proposal |
| **October 2025** | Data gathering and early development |
| **November 2025** | Feature integration |
| **December 2025** | Finalization and testing |

---

## ✅ Feature Implementation Status

| Feature | Description | Status |
| :------ | :----------- | :----: |
| **Authentication** | Email/password and Google Sign-In for users | 🟢 Completed |
| **Multi-step Registration Flow** | Location and barangay residency verification | 🟢 Completed |
| **Email Verification** | Uses Brevo API and Firestore code verification | 🟢 Completed |
| **User Management** | Firestore-based user records per barangay | 🟢 Completed |
| **Admin Dashboard** | Barangay-level management of users and posts | 🟡 In Progress |
| **Announcements Module** | Posting and viewing barangay announcements | 🟡 In Progress |
| **Incident Reports** | Private resident reports sent to officials | 🔴 Planned |
| **Document Requests** | Certificate and permit requests | 🔴 Planned |
| **Notification Center** | Real-time alerts and system updates | 🔴 Planned |
| **Vulnerable Area Mapping** | Flood-prone and evacuation maps | 🔴 Planned |
| **Push Notifications** | Firebase Cloud Messaging for alerts | 🔴 Planned |

---

## 🖼️ Screenshots

| Screen | Screenshot |
| :----- | :---------- |
| Splash Screen | <img src="assets/images/screenshots/home.png" alt="Splash Screen" width="250" /> |
| Onboarding Screen | <img src="assets/images/screenshots/registration.png" alt="Onboarding Screen" width="250" /> |
| Login Screen | <img src="assets/images/screenshots/admin_dashboard.png" alt="Login Screen" width="250" /> |
| Admin Screen | <img src="assets/images/screenshots/incident_report.png" alt="Admin Screen" width="250" /> |
| Forgot Password Screen | <img src="assets/images/screenshots/announcements.png" alt="Forgot Password Screen" width="250" /> |
| Location Selection Screen | <img src="assets/images/screenshots/announcements.png" alt="Location Selection Screen" width="250" /> |
| Residency Check Screen | <img src="assets/images/screenshots/announcements.png" alt="Residency Check Screen" width="250" /> |
| Registration Form Screen | <img src="assets/images/screenshots/announcements.png" alt="Registration Form Screen" width="250" /> |
| Email Verification Screen | <img src="assets/images/screenshots/announcements.png" alt="Email Verification Screen" width="250" /> |
| Pending Approval Screen | <img src="assets/images/screenshots/announcements.png" alt="Pending Approval Screen" width="250" /> |

---

## ⚙️ How to Run the App

### 1️⃣ Clone the Repository

```bash
git clone <repo-url>
cd TUGON-App
git checkout main
```

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Configure Firebase

1. Create a **Firebase project** in the console.
2. Add **Android and/or iOS apps** to the project.
3. Download and place the config files:

   * `android/app/google-services.json`
   * `ios/Runner/GoogleService-Info.plist`
4. Enable the following Firebase services:

   * **Firestore**
   * **Authentication** (Email/Google Sign-In)
   * **Cloud Messaging**

### 4️⃣ Run the App

```bash
flutter run
```

> ⚡ The app should launch on your connected device or simulator with full functionality.

---

## 📌 Notes / Recommendations

* Ensure **Flutter v3.24** is installed.
* Confirm **Firebase services** are properly configured before running.
* Admin functionality may require **manual Firestore role assignments**.

---

## 👥 Developers

| Name                       | GitHub                                                     |
| :------------------------- | :--------------------------------------------------------- |
| **Alcaraz, John**          | https://github.com/JohnAlcaraz02 |
| **Carranza, John Timothy** | https://github.com/Carranza-John-Timothy |
| **Donayre, Aila Roshiele** | https://github.com/ailadonayre |
| **Ramirez, Kent Ian**      | https://github.com/KentRamriez |
| **Rivera, Irish**          | https://github.com/kelleeerrrr |

---

## 🧑‍🏫 Instructor & Course Information

| Detail            | Information                                                |
| :---------------- | :--------------------------------------------------------- |
| **Course**        | Application Development and Emerging Technologies (IT 331) |
| **Instructor**    | Prof. Sean Mark Segui                                      |
| **Academic Term** | 1st Semester, A.Y. 2025–2026                               |

---

<p align="center" style="font-size:15px;">
  💡 <b style="color:#5A84F7; font-size:20px;">
    Empowering Communities. Strengthening Connections. Building the Future with
  </b>
  <img src="assets/logo/TUGON_Logo-lowercase-v2.png" 
       alt="TUGON Logo" 
       width="50" 
       style="vertical-align:middle;"/>
</p>


