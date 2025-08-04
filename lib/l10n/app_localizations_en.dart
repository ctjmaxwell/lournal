// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get getStarted => 'Get Started';

  @override
  String get login => 'Log In';

  @override
  String get welcomeBack => 'Welcome back to Lournal';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account?';

  @override
  String get registerHere => ' Register here';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get byContinuing => 'By continuing, you agree to our ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get and => ' and ';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get startPageSlogan => 'Where Language Learning Meets Journalling';

  @override
  String get signUp => 'Sign Up';

  @override
  String get syncNotes => 'Sync your notes across devices';

  @override
  String get username => 'Username';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get bySigningUp => 'By signing up, you agree to our ';

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get loginHere => ' Login here';

  @override
  String get receiveEmailResetPassword =>
      'Receive an email to reset your password';

  @override
  String resendIn(Object secondsRemaining) {
    return 'Resend in $secondsRemaining';
  }

  @override
  String get sendResetEmail => 'Send Reset Email';

  @override
  String get rememberYourPassword => 'Remember your password?';
}
