import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailCodeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String brevoApiKey = dotenv.env['BREVO_API_KEY']!;
  final String brevoApiUrl = dotenv.env['BREVO_API_URL']!;
  final String senderEmail = dotenv.env['SENDER_EMAIL']!;
  final String senderName = dotenv.env['SENDER_NAME']!;

  // Generate 6-digit code
  String generateCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Send code via Brevo API
  Future<void> sendCodeToEmail(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse(brevoApiUrl),
        headers: {
          'accept': 'application/json',
          'api-key': brevoApiKey,
          'content-type': 'application/json',
        },
        body: json.encode({
          'sender': {
            'name': senderName,
            'email': senderEmail,
          },
          'to': [
            {
              'email': email,
            }
          ],
          'subject': 'Your Verification Code - TUGON App',
          'htmlContent': '''
            <!DOCTYPE html>
            <html>
            <head>
              <style>
                body { 
                  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
                  line-height: 1.6; 
                  color: #333;
                  margin: 0;
                  padding: 0;
                  background-color: #f5f5f5;
                }
                .container { 
                  max-width: 600px; 
                  margin: 40px auto; 
                  background: white;
                  border-radius: 12px;
                  overflow: hidden;
                  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                }
                .header { 
                  background: #FFB300;
                  color: white; 
                  padding: 40px 20px; 
                  text-align: center; 
                }
                .header h1 {
                  margin: 0;
                  font-size: 28px;
                  font-weight: 600;
                }
                .content { 
                  padding: 40px 30px; 
                }
                .code-box { 
                  background: #FFF8E1;
                  border: 3px solid #FFB300; 
                  border-radius: 12px; 
                  padding: 30px; 
                  text-align: center; 
                  margin: 30px 0; 
                }
                .code { 
                  font-size: 48px; 
                  font-weight: bold; 
                  color: #FFB300; 
                  letter-spacing: 12px;
                  font-family: 'Courier New', monospace;
                }
                .info {
                  background: #F8F9FA;
                  border-left: 4px solid #FFB300;
                  padding: 15px;
                  margin: 20px 0;
                  border-radius: 4px;
                }
                .footer { 
                  text-align: center; 
                  padding: 30px 20px; 
                  color: #666; 
                  font-size: 14px;
                  background: #F8F9FA;
                  border-top: 1px solid #E0E0E0;
                }
                .button {
                  display: inline-block;
                  padding: 12px 30px;
                  background: #FFB300;
                  color: white;
                  text-decoration: none;
                  border-radius: 6px;
                  margin: 20px 0;
                  font-weight: 600;
                }
              </style>
            </head>
            <body>
              <div class="container">
                <div class="header">
                  <h1>Verify your email</h1>
                </div>
                <div class="content">
                  <p style="font-size: 16px;">Hello,</p>
                  <p style="font-size: 16px;">Thank you for signing up for <strong>TUGON App</strong>! To complete your registration, please verify your email address using the code below:</p>
                  
                  <div class="code-box">
                    <div class="code">$code</div>
                  </div>
                  
                  <div class="info">
                    <p style="margin: 5px 0;"><strong>⏱️ This code will expire in 10 minutes.</strong></p>
                    <p style="margin: 5px 0;">Enter this code in the app to verify your email address.</p>
                  </div>
                  
                  <p style="font-size: 14px; color: #666; margin-top: 30px;">
                    If you didn't create an account with Tugon App, please ignore this email or contact our support team.
                  </p>
                </div>
                <div class="footer">
                  <p style="margin: 5px 0;">© 2025 Tugon App. All rights reserved.</p>
                  <p style="margin: 5px 0; font-size: 12px;">This is an automated email, please do not reply.</p>
                </div>
              </div>
            </body>
            </html>
          ''',
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send email: ${response.body}');
      }

      print('✅ Email sent successfully via Brevo');
    } catch (e) {
      print('❌ Error sending email: ${e.toString()}');
      throw Exception('Failed to send code via email: ${e.toString()}');
    }
  }

  // Store code in Firestore AND send via email
  Future<String> storeAndSendVerificationCode(String email) async {
    try {
      final code = generateCode();
      final expiresAt = DateTime.now().add(Duration(minutes: 10));

      print('📝 Storing code for $email');

      // Store in Firestore
      await _firestore.collection('verification_codes').doc(email).set({
        'code': code,
        'email': email,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'verified': false,
        'createdAt': Timestamp.now(),
      });

      print('📧 Sending code via Brevo');

      // Send via Brevo
      await sendCodeToEmail(email, code);

      return code;
    } catch (e) {
      print('❌ Error: ${e.toString()}');
      throw Exception('Failed to store and send code: ${e.toString()}');
    }
  }

  // Verify the code
  Future<bool> verifyCode(String email, String code) async {
    try {
      print('🔍 Verifying code for $email');

      final doc = await _firestore
          .collection('verification_codes')
          .doc(email)
          .get();

      if (!doc.exists) {
        print('❌ No code found for this email');
        return false;
      }

      final data = doc.data()!;
      final storedCode = data['code'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final verified = data['verified'] as bool;

      print('Stored code: $storedCode, Input code: $code');
      print('Expires at: $expiresAt, Now: ${DateTime.now()}');
      print('Already verified: $verified');

      if (storedCode == code &&
          DateTime.now().isBefore(expiresAt) &&
          !verified) {

        print('✅ Code verified successfully');

        await _firestore
            .collection('verification_codes')
            .doc(email)
            .update({'verified': true});

        return true;
      }

      print('❌ Code verification failed');
      return false;
    } catch (e) {
      print('❌ Error verifying code: ${e.toString()}');
      throw Exception('Failed to verify code: ${e.toString()}');
    }
  }

  // Resend code
  Future<String> resendCode(String email) async {
    print('🔄 Resending code for $email');
    return await storeAndSendVerificationCode(email);
  }
}