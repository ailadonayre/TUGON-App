import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  print('🚀 Starting Firestore seeding...\n');

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print('✅ Firebase initialized\n');

    final firestore = FirebaseFirestore.instance;

    // Define barangay data
    final barangays = [
      {
        'id': 'BATANGAS__BATANGAS_CITY__Alangilan',
        'metadata': {
          'province': 'BATANGAS',
          'city': 'BATANGAS CITY',
          'barangay': 'Alangilan',
          'createdAt': FieldValue.serverTimestamp(),
        }
      },
      {
        'id': 'BATANGAS__BATANGAS_CITY__Tinga_Itaas',
        'metadata': {
          'province': 'BATANGAS',
          'city': 'BATANGAS CITY',
          'barangay': 'Tinga Itaas',
          'createdAt': FieldValue.serverTimestamp(),
        }
      },
      {
        'id': 'BATANGAS__MUNICIPALITY_OF_AGONCILLO__Banyaga',
        'metadata': {
          'province': 'BATANGAS',
          'city': 'MUNICIPALITY OF AGONCILLO',
          'barangay': 'Banyaga',
          'createdAt': FieldValue.serverTimestamp(),
        }
      },
    ];

    // Create each barangay document
    for (var barangay in barangays) {
      final docId = barangay['id'] as String;
      final metadata = barangay['metadata'] as Map<String, dynamic>;

      await firestore.collection('barangays').doc(docId).set(metadata);

      print('📍 Created: ${metadata['barangay']}, ${metadata['city']}');
    }

    print('\n✅ Successfully seeded ${barangays.length} barangay documents!');
    print('\n📊 Firestore Structure:');
    print('   barangays/');
    for (var barangay in barangays) {
      print('   ├── ${barangay['id']}');
      print('   │   └── users/ (subcollection - will be populated on registration)');
    }

    print('\n💡 Next steps:');
    print('   1. Run the app: flutter run');
    print('   2. Register a test user');
    print('   3. To create admin account:');
    print('      - Go to Firestore Console');
    print('      - Navigate to: barangays → [barangay_id] → users → [user_uid]');
    print('      - Add field: isAdmin: true');
    print('      - Update field: status: "approved"');

  } catch (e) {
    print('❌ Error seeding Firestore: $e');
    print('\nTroubleshooting:');
    print('   1. Ensure Firebase is initialized in your project');
    print('   2. Check google-services.json is in android/app/');
    print('   3. Verify Firestore is enabled in Firebase Console');
    print('   4. Check your internet connection');
  }
}