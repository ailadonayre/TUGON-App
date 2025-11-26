import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/post_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/login_screen.dart';
import 'utils/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  try {
    final options = _firebaseOptionsFromEnv();
    await Firebase.initializeApp(options: options);
    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint('Firebase initialization failed: $e');
    debugPrintStack(stackTrace: stack);
    runApp(const FirebaseErrorApp());
  }
}

FirebaseOptions _firebaseOptionsFromEnv() {
  String? e(String key) => dotenv.env[key];

  if (kIsWeb) {
    return FirebaseOptions(
      apiKey: e('WEB_API_KEY') ?? (throw ArgumentError('Missing WEB_API_KEY')),
      appId: e('WEB_APP_ID') ?? (throw ArgumentError('Missing WEB_APP_ID')),
      messagingSenderId: e('WEB_MESSAGING_SENDER_ID') ?? (throw ArgumentError('Missing WEB_MESSAGING_SENDER_ID')),
      projectId: e('WEB_PROJECT_ID') ?? (throw ArgumentError('Missing WEB_PROJECT_ID')),
      authDomain: e('WEB_AUTH_DOMAIN'),
      storageBucket: e('WEB_STORAGE_BUCKET'),
      measurementId: e('WEB_MEASUREMENT_ID'),
    );
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return FirebaseOptions(
        apiKey: e('ANDROID_API_KEY') ?? (throw ArgumentError('Missing ANDROID_API_KEY')),
        appId: e('ANDROID_APP_ID') ?? (throw ArgumentError('Missing ANDROID_APP_ID')),
        messagingSenderId: e('ANDROID_MESSAGING_SENDER_ID') ?? (throw ArgumentError('Missing ANDROID_MESSAGING_SENDER_ID')),
        projectId: e('ANDROID_PROJECT_ID') ?? (throw ArgumentError('Missing ANDROID_PROJECT_ID')),
        storageBucket: e('ANDROID_STORAGE_BUCKET'),
      );

    case TargetPlatform.iOS:
      return FirebaseOptions(
        apiKey: e('IOS_API_KEY') ?? (throw ArgumentError('Missing IOS_API_KEY')),
        appId: e('IOS_APP_ID') ?? (throw ArgumentError('Missing IOS_APP_ID')),
        messagingSenderId: e('IOS_MESSAGING_SENDER_ID') ?? (throw ArgumentError('Missing IOS_MESSAGING_SENDER_ID')),
        projectId: e('IOS_PROJECT_ID') ?? (throw ArgumentError('Missing IOS_PROJECT_ID')),
        storageBucket: e('IOS_STORAGE_BUCKET'),
        androidClientId: e('IOS_ANDROID_CLIENT_ID'),
        iosClientId: e('IOS_CLIENT_ID'),
        iosBundleId: e('IOS_BUNDLE_ID'),
      );

    case TargetPlatform.macOS:
      return FirebaseOptions(
        apiKey: e('MACOS_API_KEY') ?? (throw ArgumentError('Missing MACOS_API_KEY')),
        appId: e('MACOS_APP_ID') ?? (throw ArgumentError('Missing MACOS_APP_ID')),
        messagingSenderId: e('MACOS_MESSAGING_SENDER_ID') ?? (throw ArgumentError('Missing MACOS_MESSAGING_SENDER_ID')),
        projectId: e('MACOS_PROJECT_ID') ?? (throw ArgumentError('Missing MACOS_PROJECT_ID')),
        storageBucket: e('MACOS_STORAGE_BUCKET'),
        androidClientId: e('MACOS_ANDROID_CLIENT_ID'),
        iosClientId: e('MACOS_CLIENT_ID'),
        iosBundleId: e('MACOS_BUNDLE_ID'),
      );

    case TargetPlatform.windows:
      return FirebaseOptions(
        apiKey: e('WINDOWS_API_KEY') ?? (throw ArgumentError('Missing WINDOWS_API_KEY')),
        appId: e('WINDOWS_APP_ID') ?? (throw ArgumentError('Missing WINDOWS_APP_ID')),
        messagingSenderId: e('WINDOWS_MESSAGING_SENDER_ID') ?? (throw ArgumentError('Missing WINDOWS_MESSAGING_SENDER_ID')),
        projectId: e('WINDOWS_PROJECT_ID') ?? (throw ArgumentError('Missing WINDOWS_PROJECT_ID')),
        authDomain: e('WINDOWS_AUTH_DOMAIN'),
        storageBucket: e('WINDOWS_STORAGE_BUCKET'),
        measurementId: e('WINDOWS_MEASUREMENT_ID'),
      );

    default:
      throw UnsupportedError('Platform not configured for Firebase in .env.');
  }
}

class FirebaseErrorApp extends StatelessWidget {
  const FirebaseErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Text(
            'Failed to initialize Firebase.\nPlease check your configuration.',
            style: TextStyle(color: AppColors.coralRed, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'TUGON',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: AppColors.brightBlue,
          scaffoldBackgroundColor: AppColors.white,
          colorScheme: ColorScheme.light(
            primary: AppColors.brightBlue,
            secondary: AppColors.coralRed,
            tertiary: AppColors.goldenYellow,
            surface: AppColors.white,
            onPrimary: AppColors.white,
            onSecondary: AppColors.white,
            onSurface: AppColors.charcoalBlack,
          ),
          textTheme: GoogleFonts.dmSansTextTheme(
            ThemeData.light().textTheme.apply(
              bodyColor: AppColors.charcoalBlack,
              displayColor: AppColors.charcoalBlack,
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.charcoalBlack,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoalBlack,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.brightBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.coralRed, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.coralRed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brightBlue,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              textStyle: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            color: AppColors.white,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}
