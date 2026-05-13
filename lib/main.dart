import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? firebaseError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    firebaseError = error;
  }

  runApp(MyApp(firebaseError: firebaseError));
}

class MyApp extends StatelessWidget {
  final Object? firebaseError;

  const MyApp({super.key, this.firebaseError});

  @override
  Widget build(BuildContext context) {
    if (firebaseError != null) {
      return MaterialApp(
        title: 'FYP Management System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: FirebaseSetupErrorScreen(error: firebaseError!),
      );
    }

    return MultiProvider(
      providers: [Provider(create: (_) => AuthService())],
      child: MaterialApp(
        title: 'FYP Management System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {'/login': (_) => const LoginScreen()},
        home: const SplashScreen(),
      ),
    );
  }
}

class FirebaseSetupErrorScreen extends StatelessWidget {
  final Object error;

  const FirebaseSetupErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Firebase is not configured',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The app loaded, but Firebase failed during startup. Add your Firebase configuration, then restart Flutter.',
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    error.toString(),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
