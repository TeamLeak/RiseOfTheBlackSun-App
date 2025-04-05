import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/two_factor_verification_screen.dart';
import 'features/two_factor/screens/home_screen.dart';
import 'features/two_factor/screens/two_factor_setup_screen.dart';
import 'features/two_factor/screens/backup_codes_screen.dart';
import 'features/two_factor/screens/security_dashboard_screen.dart';
import 'features/two_factor/screens/device_management_screen.dart';
import 'features/two_factor/screens/activity_timeline_screen.dart';
import 'features/two_factor/screens/security_preferences_screen.dart';
import 'features/auth/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const BlackSunApp());
}

class BlackSunApp extends StatefulWidget {
  const BlackSunApp({super.key});

  @override
  State<BlackSunApp> createState() => _BlackSunAppState();
}

class _BlackSunAppState extends State<BlackSunApp> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        title: 'BlackSun 2FA Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.accentColor),
          useMaterial3: true,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'BlackSun 2FA Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.accentColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        useMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      home: _isLoggedIn ? const HomeScreen() : const LoginScreen(),
      routes: {
        // Basic routes
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        '/two-factor-setup': (_) => TwoFactorSetupScreen(isEnabled: false),
        BackupCodesScreen.routeName: (_) => const BackupCodesScreen(),
        
        // Security Dashboard and related screens
        '/security-dashboard': (_) => const SecurityDashboardScreen(),
        DeviceManagementScreen.routeName: (_) => const DeviceManagementScreen(),
        ActivityTimelineScreen.routeName: (_) => const ActivityTimelineScreen(),
        SecurityPreferencesScreen.routeName: (_) => const SecurityPreferencesScreen(),
        
        // Legacy screens
        '/login-history': (_) => const Scaffold(body: Center(child: Text('Login History'))),
        '/change-password': (_) => const Scaffold(body: Center(child: Text('Change Password'))),
      },
      // Only handle specific routes that need arguments
      onGenerateRoute: (settings) {
        if (settings.name == TwoFactorVerificationScreen.routeName) {
          // Make sure we always have a valid email
          final args = settings.arguments as Map<String, dynamic>?;
          final email = args?['email'] as String? ?? 'user@example.com';
          
          return MaterialPageRoute(
            builder: (context) => TwoFactorVerificationScreen(email: email),
          );
        }
        // Return null for unknown routes - let Flutter handle the error
        return null;
      },
    );
  }
}
