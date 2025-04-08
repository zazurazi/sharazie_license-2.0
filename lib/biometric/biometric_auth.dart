import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricAuth {
  final LocalAuthentication auth = LocalAuthentication();

  /// ✅ Check if the device supports biometrics
  Future<bool> isBiometricAvailable() async {
    try {
      return await auth.canCheckBiometrics;
    } catch (e) {
      print("Error checking biometrics: $e");
      return false;
    }
  }

  /// ✅ Authenticate using fingerprint/face ID
  Future<bool> authenticate() async {
    try {
      bool isAuthenticated = await auth.authenticate(
        localizedReason: 'Use your fingerprint or face to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        await _saveBiometricLogin();
      }

      return isAuthenticated;
    } catch (e) {
      print("Biometric authentication error: $e");
      return false;
    }
  }

  /// ✅ Save the last logged-in email for biometric authentication
  Future<void> _saveBiometricLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('last_logged_in_email');
    if (email != null) {
      await prefs.setBool('biometric_enabled', true);
    }
  }

  /// ✅ Check if biometric login is enabled
  Future<bool> isBiometricEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  /// ✅ Get the saved email for biometric login
  Future<String?> getSavedEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_logged_in_email');
  }
}
