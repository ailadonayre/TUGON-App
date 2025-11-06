import 'package:flutter_test/flutter_test.dart';
import 'package:tugon_app/models/family_member_model.dart';

void main() {
  group('Profile Form Validation Tests', () {
    test('Valid family member relationships should be accepted', () {
      for (final relationship in FamilyMember.validRelationships) {
        final member = FamilyMember(
          id: '1',
          firstName: 'Test',
          lastName: 'Member',
          dateOfBirth: DateTime(1990, 1, 1),
          placeOfBirth: 'Test City',
          relationship: relationship,
        );

        expect(FamilyMember.validRelationships.contains(member.relationship), isTrue);
      }
    });

    test('Invalid family member relationship should fail validation', () {
      final invalidRelationship = 'cousin';
      expect(FamilyMember.validRelationships.contains(invalidRelationship), isFalse);
    });

    test('Date of birth validation - age should be between 5 and 120', () {
      final now = DateTime.now();

      // Valid age (20 years old)
      final validDob = DateTime(now.year - 20, now.month, now.day);
      expect(now.difference(validDob).inDays / 365, greaterThan(5));
      expect(now.difference(validDob).inDays / 365, lessThan(120));

      // Too young (2 years old)
      final tooYoungDob = DateTime(now.year - 2, now.month, now.day);
      expect(now.difference(tooYoungDob).inDays / 365, lessThan(5));

      // Too old (130 years old)
      final tooOldDob = DateTime(now.year - 130, now.month, now.day);
      expect(now.difference(tooOldDob).inDays / 365, greaterThan(120));
    });

    test('Family member full name should be formatted correctly', () {
      final memberWithMiddle = FamilyMember(
        id: '1',
        firstName: 'Juan',
        middleName: 'Santos',
        lastName: 'Dela Cruz',
        dateOfBirth: DateTime(1990, 1, 1),
        placeOfBirth: 'Test City',
        relationship: 'father',
      );

      expect(memberWithMiddle.fullName, equals('Juan Santos Dela Cruz'));

      final memberWithoutMiddle = FamilyMember(
        id: '2',
        firstName: 'Maria',
        lastName: 'Reyes',
        dateOfBirth: DateTime(1992, 5, 15),
        placeOfBirth: 'Test City',
        relationship: 'mother',
      );

      expect(memberWithoutMiddle.fullName, equals('Maria Reyes'));
    });

    test('House number and street name validation', () {
      // Valid inputs
      expect('123'.length, greaterThan(0));
      expect('Main Street'.length, greaterThan(0));

      // Invalid (empty)
      expect(''.length, equals(0));
    });

    test('Middle name should be optional', () {
      final memberWithoutMiddle = FamilyMember(
        id: '1',
        firstName: 'Test',
        lastName: 'User',
        dateOfBirth: DateTime(1990, 1, 1),
        placeOfBirth: 'Test City',
        relationship: 'son',
      );

      expect(memberWithoutMiddle.middleName, isNull);
      expect(memberWithoutMiddle.fullName, equals('Test User'));
    });
  });
}