// tools/seed.js
/**
 * This script seeds barangay data into your Firestore database.
 * Run using: node seed.js
 */

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Initialize Firebase Admin SDK using the service account key
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function seedBarangays() {
  const barangays = [
    {
      id: "BATANGAS__BATANGAS_CITY__Alangilan",
      province: "BATANGAS",
      city: "BATANGAS CITY",
      barangay: "Alangilan",
    },
    {
      id: "BATANGAS__BATANGAS_CITY__Tinga_Itaas",
      province: "BATANGAS",
      city: "BATANGAS CITY",
      barangay: "Tinga Itaas",
    },
    {
      id: "BATANGAS__MUNICIPALITY_OF_AGONCILLO__Banyaga",
      province: "BATANGAS",
      city: "MUNICIPALITY OF AGONCILLO",
      barangay: "Banyaga",
    },
  ];

  console.log("Starting to seed barangays...");

  for (const data of barangays) {
    const docRef = db.collection("barangays").doc(data.id);
    await docRef.set({
      province: data.province,
      city: data.city,
      barangay: data.barangay,
    });
    console.log(`Added ${data.barangay} (${data.city})`);
  }

  console.log("Seeding complete!");
  process.exit(0);
}

seedBarangays().catch((err) => {
  console.error("Error seeding data:", err);
  process.exit(1);
});