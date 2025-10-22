// App-wide constants
class AppConstants {
  // App info
  static const String appName = 'TUGON';
  static const String appTagline = 'Barangay Help & Service App';

  // Timing
  static const int splashDuration = 2; // seconds
  static const int otpResendTimeout = 60; // seconds
  static const int approvalWaitTime = 48; // hours

  // Validation
  static const int minPasswordLength = 6;
  static const int phoneNumberLength = 11;
  static const int otpLength = 6;
  static const int minNameLength = 3;

  // User status
  static const String statusPendingReview = 'pending_review';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusPartial = 'partial';

  // Collection names
  static const String collectionBarangays = 'barangays';
  static const String collectionUsers = 'users';
  static const String collectionAnnouncements = 'announcements';
  static const String collectionReports = 'reports';
  static const String collectionDocuments = 'documents';

  // Error messages
  static const String errorGeneric = 'An error occurred. Please try again.';
  static const String errorNetwork = 'Please check your internet connection.';
  static const String errorAuth = 'Authentication failed. Please try again.';

  // Success messages
  static const String successRegistration = 'Registration successful!';
  static const String successLogin = 'Login successful!';
  static const String successPasswordReset = 'Password reset email sent!';

  // Phone format
  static const String phonePrefix = '+63';
  static const String phonePattern = r'^09\d{9}$';

  // Email pattern
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
}