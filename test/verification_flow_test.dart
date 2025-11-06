import 'package:flutter_test/flutter_test.dart';
import 'package:tugon_app/models/user_model.dart';

void main() {
  group('Verification Status Flow Tests', () {
    test('New user should start with pending_admin status', () {
      final user = UserModel(
        uid: 'test123',
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '09123456789',
        location: LocationData(
          province: 'Test Province',
          city: 'Test City',
          barangay: 'Test Barangay',
        ),
        createdAt: DateTime.now(),
      );

      expect(user.verificationStatus, equals('pending_admin'));
      expect(user.emailVerified, isFalse);
      expect(user.profileCompleted, isFalse);
    });

    test('Admin approval should change status to partially_verified', () {
      var user = UserModel(
        uid: 'test123',
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '09123456789',
        location: LocationData(
          province: 'Test Province',
          city: 'Test City',
          barangay: 'Test Barangay',
        ),
        verificationStatus: 'pending_admin',
        createdAt: DateTime.now(),
      );

      // Simulate admin approval
      user = user.copyWith(verificationStatus: 'partially_verified');

      expect(user.verificationStatus, equals('partially_verified'));
    });

    test('Email verification and profile completion should result in fully_verified', () {
      var user = UserModel(
        uid: 'test123',
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '09123456789',
        location: LocationData(
          province: 'Test Province',
          city: 'Test City',
          barangay: 'Test Barangay',
        ),
        verificationStatus: 'partially_verified',
        createdAt: DateTime.now(),
      );

      // Simulate email verification
      user = user.copyWith(emailVerified: true);
      expect(user.emailVerified, isTrue);

      // Simulate profile completion
      user = user.copyWith(
        profileCompleted: true,
        firstName: 'Test',
        lastName: 'User',
        dateOfBirth: DateTime(1990, 1, 1),
        placeOfBirth: 'Test City',
        houseNumber: '123',
        streetName: 'Test Street',
      );
      expect(user.profileCompleted, isTrue);

      // When both email verified and profile completed
      if (user.emailVerified && user.profileCompleted) {
        user = user.copyWith(verificationStatus: 'fully_verified');
      }

      expect(user.verificationStatus, equals('fully_verified'));
    });

    test('Partial verification should not allow posting', () {
      final user = UserModel(
        uid: 'test123',
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '09123456789',
        location: LocationData(
          province: 'Test Province',
          city: 'Test City',
          barangay: 'Test Barangay',
        ),
        verificationStatus: 'partially_verified',
        createdAt: DateTime.now(),
      );

      final canPost = user.verificationStatus == 'fully_verified';
      expect(canPost, isFalse);
    });

    test('Full verification should allow posting', () {
      final user = UserModel(
        uid: 'test123',
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '09123456789',
        location: LocationData(
          province: 'Test Province',
          city: 'Test City',
          barangay: 'Test Barangay',
        ),
        verificationStatus: 'fully_verified',
        emailVerified: true,
        profileCompleted: true,
        createdAt: DateTime.now(),
      );

      final canPost = user.verificationStatus == 'fully_verified';
      expect(canPost, isTrue);
    });
  });
}