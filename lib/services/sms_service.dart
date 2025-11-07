import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// SMS Verification Service (Stubbed for Development)
///
/// TODO: Production Implementation Required
/// 1. Sign up for Twilio account: https://www.twilio.com/try-twilio
/// 2. Get credentials from Twilio Console:
///    - TWILIO_ACCOUNT_SID
///    - TWILIO_AUTH_TOKEN
///    - TWILIO_PHONE_NUMBER (your Twilio phone number)
/// 3. Add credentials to .env file
/// 4. Install Twilio SDK: twilio_flutter: ^0.0.9
/// 5. Replace stub methods with real Twilio API calls
///
/// Example Twilio implementation:
/// ```dart
/// import 'package:twilio_flutter/twilio_flutter.dart';
///
/// final twilioFlutter = TwilioFlutter(
///   accountSid: dotenv.env['TWILIO_ACCOUNT_SID']!,
///   authToken: dotenv.env['TWILIO_AUTH_TOKEN']!,
///   twilioNumber: dotenv.env['TWILIO_PHONE_NUMBER']!,
/// );
///
/// await twilioFlutter.sendSMS(
///   toNumber: phoneNumber,
///   messageBody: 'Your TUGON verification code is: $code',
/// );
/// ```
class SmsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate a 6-digit numeric verification code
  String generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Send SMS verification code (STUBBED)
  /// In production, this should send via Twilio, AWS SNS, or similar provider
  ///
  /// Returns: The generated code (for testing purposes)
  Future<String> sendVerificationSms(String phoneNumber) async {
    try {
      final code = generateVerificationCode();
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));

      // Store code in Firestore
      await _firestore.collection('phone_verification_codes').doc(phoneNumber).set({
        'code': code,
        'phoneNumber': phoneNumber,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'verified': false,
        'createdAt': Timestamp.now(),
        'attempts': 0,
      });

      // TODO: Replace with real SMS provider
      if (kDebugMode) {
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📱 SMS VERIFICATION CODE (DEBUG MODE)');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('Phone: $phoneNumber');
        print('Code: $code');
        print('Expires: $expiresAt');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('⚠️  In production, this will be sent via SMS provider');
        print('⚠️  Add Twilio credentials to .env and uncomment provider code');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }

      // STUB: In production, uncomment and configure Twilio:
      /*
      final twilioFlutter = TwilioFlutter(
        accountSid: dotenv.env['TWILIO_ACCOUNT_SID']!,
        authToken: dotenv.env['TWILIO_AUTH_TOKEN']!,
        twilioNumber: dotenv.env['TWILIO_PHONE_NUMBER']!,
      );

      await twilioFlutter.sendSMS(
        toNumber: phoneNumber,
        messageBody: 'Your TUGON verification code is: $code. Valid for 10 minutes.',
      );
      */

      return code; // Return code for development testing
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending SMS: $e');
      }
      throw Exception('Failed to send verification code: ${e.toString()}');
    }
  }

  /// Verify the SMS code entered by user
  ///
  /// Returns: true if code is valid and not expired, false otherwise
  Future<bool> verifyPhoneCode(String phoneNumber, String code) async {
    try {
      final doc = await _firestore
          .collection('phone_verification_codes')
          .doc(phoneNumber)
          .get();

      if (!doc.exists) {
        if (kDebugMode) print('❌ No verification code found for $phoneNumber');
        return false;
      }

      final data = doc.data()!;
      final storedCode = data['code'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final verified = data['verified'] as bool;
      final attempts = (data['attempts'] as int?) ?? 0;

      // Check attempt limit (prevent brute force)
      if (attempts >= 5) {
        if (kDebugMode) print('❌ Too many verification attempts');
        throw Exception('Too many verification attempts. Please request a new code.');
      }

      // Increment attempts
      await _firestore
          .collection('phone_verification_codes')
          .doc(phoneNumber)
          .update({'attempts': attempts + 1});

      // Validate code
      if (storedCode == code &&
          DateTime.now().isBefore(expiresAt) &&
          !verified) {
        // Mark as verified
        await _firestore
            .collection('phone_verification_codes')
            .doc(phoneNumber)
            .update({'verified': true});

        if (kDebugMode) print('✅ Phone verified successfully: $phoneNumber');
        return true;
      }

      if (kDebugMode) {
        if (DateTime.now().isAfter(expiresAt)) {
          print('❌ Verification code expired');
        } else if (verified) {
          print('❌ Code already used');
        } else {
          print('❌ Invalid verification code');
        }
      }

      return false;
    } catch (e) {
      if (kDebugMode) print('❌ Error verifying code: $e');
      throw Exception('Failed to verify code: ${e.toString()}');
    }
  }

  /// Resend verification code with cooldown check
  Future<String> resendVerificationCode(String phoneNumber) async {
    try {
      // Check if recent code exists
      final doc = await _firestore
          .collection('phone_verification_codes')
          .doc(phoneNumber)
          .get();

      if (doc.exists) {
        final createdAt = (doc.data()!['createdAt'] as Timestamp).toDate();
        final cooldownSeconds = 60;
        final timeSinceCreation = DateTime.now().difference(createdAt).inSeconds;

        if (timeSinceCreation < cooldownSeconds) {
          final remainingSeconds = cooldownSeconds - timeSinceCreation;
          throw Exception('Please wait $remainingSeconds seconds before resending');
        }
      }

      // Send new code
      return await sendVerificationSms(phoneNumber);
    } catch (e) {
      if (kDebugMode) print('❌ Error resending code: $e');
      rethrow;
    }
  }

  /// Clean up expired verification codes (maintenance method)
  Future<void> cleanupExpiredCodes() async {
    try {
      final now = Timestamp.now();
      final expiredDocs = await _firestore
          .collection('phone_verification_codes')
          .where('expiresAt', isLessThan: now)
          .get();

      for (var doc in expiredDocs.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) print('✅ Cleaned up ${expiredDocs.docs.length} expired codes');
    } catch (e) {
      if (kDebugMode) print('❌ Error cleaning up codes: $e');
    }
  }
}