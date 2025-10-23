// tools/seed.js
/**
 * Firestore Seeder Script
 * -----------------------
 * This script seeds barangay data and a sample admin user into Firestore.
 *
 * Run using: node seed.js
 *
 * Make sure:
 * - You have a valid serviceAccountKey.json in the same directory.
 * - You’ve run `npm install firebase-admin` beforehand.
 */

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Barangay data
const barangays = [
  {
    id: "BATANGAS__BATANGAS_CITY__Alangilan",
    data: {
      province: "BATANGAS",
      city: "BATANGAS CITY",
      barangay: "Alangilan",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
    },
  },
  {
    id: "BATANGAS__BATANGAS_CITY__Tinga_Itaas",
    data: {
      province: "BATANGAS",
      city: "BATANGAS CITY",
      barangay: "Tinga Itaas",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
    },
  },
  {
    id: "BATANGAS__MUNICIPALITY_OF_AGONCILLO__Banyaga",
    data: {
      province: "BATANGAS",
      city: "MUNICIPALITY OF AGONCILLO",
      barangay: "Banyaga",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
    },
  },
];

// Sample admin user data
const sampleAdmin = {
  fullName: "Barangay Admin",
  email: "admin@alangilan.gov.ph",
  phone: "09123456789",
  location: {
    province: "BATANGAS",
    city: "BATANGAS CITY",
    barangay: "Alangilan",
  },
  status: "approved",
  phoneVerified: true,
  emailVerified: true,
  isAdmin: true,
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
};

// Replace with actual Firebase Auth UID later
const SAMPLE_ADMIN_UID = "SAMPLE_ADMIN_UID";

// Seeder function
async function seedFirestore() {
  try {
    console.log("Starting Firestore seeding...");

    for (const barangay of barangays) {
      console.log(`Creating barangay: ${barangay.id}`);

      await db
        .collection("barangays")
        .doc(barangay.id)
        .set(barangay.data, { merge: true });

      console.log(`${barangay.id} created or updated successfully`);
    }

    // Add sample admin under Alangilan barangay
    console.log("Creating sample admin user entry...");

    await db
      .collection("barangays")
      .doc("BATANGAS__BATANGAS_CITY__Alangilan")
      .collection("users")
      .doc(SAMPLE_ADMIN_UID)
      .set(sampleAdmin, { merge: true });

    console.log("Sample admin user data created.");
    console.log("Remember to:");
    console.log("  1. Create this user in Firebase Auth Console.");
    console.log("  2. Replace SAMPLE_ADMIN_UID with their actual UID.");
    console.log("  3. Re-run this script to link it properly.");

    console.log("Firestore seeding completed successfully.");
    console.log(`Total barangays created: ${barangays.length}`);

    process.exit(0);
  } catch (error) {
    console.error("Error seeding Firestore:", error);
    process.exit(1);
  }
}

seedFirestore();