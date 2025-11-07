import 'package:flutter_test/flutter_test.dart';
import 'package:tugon_app/models/user_model.dart';

void main() {
  group('Phone Verification Flow Tests', () {
    test('User starts as pending_admin after registration', () {
      final user = UserModel(
        uid: 'test_uid',
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '09123456789',
        location: LocationData(
          province: 'BATANGAS',
          city: 'BATANGAS CITY',
          barangay: 'Alangilan',
        ),
        status: 'pending_review',
        verificationStatus: 'pending_admin',
        phoneVerified: false,
        emailVerified: true,
        profileCompleted: false,
        createdAt: DateTime.now(),
      );

      expect(user.verificationStatus, 'pending_admin');
      expect(user.phoneVerified, false);
      expect(user.profileCompleted, false);
      expect(user.isFullyVerified, false);
    });

    test('User becomes partially_verified after admin approval', () {
      final user = UserModel(
        uid: 'test_uid',
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '09123456789',
        location: LocationData(
          province: 'BATANGAS',
          city: 'BATANGAS CITY',
          barangay: 'Alangilan',
        ),
        status: 'approved',
        verificationStatus: 'partially_verified',
        phoneVerified: false,
        emailVerified: true,
        profileCompleted: false,
        createdAt: DateTime.now(),
      );

      expect(user.status, 'approved');
      expect(user.verificationStatus, 'partially_verified');
      expect(user.isFullyVerified, false);
    });

    test('Phone verification alone does not grant full verification', () {
      final user = UserModel(
        uid: 'test_uid',
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '09123456789',
        location: LocationData(
          province: 'BATANGAS',
          city: 'BATANGAS CITY',
          barangay: 'Alangilan',
        ),
        status: 'approved',
        verificationStatus: 'partially_verified',
        phoneVerified: true,
        emailVerified: true,
        profileCompleted: false,
        createdAt: DateTime.now(),
      );

      expect(user.phoneVerified, true);
      expect(user.profileCompleted, false);
      expect(user.isFullyVerified, false);
    });

    test('Profile completion alone does not grant full verification', () {
      final user = UserModel(
        uid: 'test_uid',
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '09123456789',
        location: LocationData(
          province: 'BATANGAS',
          city: 'BATANGAS CITY',
          barangay: 'Alangilan',
        ),
        status: 'approved',
        verificationStatus: 'partially_verified',
        phoneVerified: false,
        emailVerified: true,
        profileCompleted: true,
        createdAt: DateTime.now(),
      );

      expect(user.phoneVerified, false);
      expect(user.profileCompleted, true);
      expect(user.isFullyVerified, false);
    });

    test('User becomes fully_verified with phone + profile completion', () {
      final user = UserModel(
        uid: 'test_uid',
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '09123456789',
        location: LocationData(
          province: 'BATANGAS',
          city: 'BATANGAS CITY',
          barangay: 'Alangilan',
        ),
        status: 'approved',
        verificationStatus: 'fully_verified',
        phoneVerified: true,
        emailVerified: true,
        profileCompleted: true,
        createdAt: DateTime.now(),
      );

      expect(user.phoneVerified, true);
      expect(user.profileCompleted, true);
      expect(user.verificationStatus, 'fully_verified');
      expect(user.isFullyVerified, true);
    });

    test('Email verification status is independent', () {
      final user = UserModel(
        uid: 'test_uid',
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '09123456789',
        location: LocationData(
          province: 'BATANGAS',
          city: 'BATANGAS CITY',
          barangay: 'Alangilan',
        ),
        status: 'approved',
        verificationStatus: 'fully_verified',
        phoneVerified: true,
        emailVerified: true, // Used only for registration
        profileCompleted: true,
        createdAt: DateTime.now(),
      );

      // Email verified at registration, but doesn't affect full verification
      expect(user.emailVerified, true);
      expect(user.isFullyVerified, true);

      // Full verification depends on phone + profile
      final userWithoutEmail = user.copyWith(emailVerified: false);
      expect(userWithoutEmail.isFullyVerified, true); // Still fully verified
    });
  });
}