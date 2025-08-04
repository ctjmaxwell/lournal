// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get getStarted => 'Beginnen';

  @override
  String get login => 'Inloggen';

  @override
  String get welcomeBack => 'Welkom terug bij Lournal';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Wachtwoord';

  @override
  String get forgotPassword => 'Wachtwoord vergeten?';

  @override
  String get dontHaveAnAccount => 'Nog geen account?';

  @override
  String get registerHere => ' Hier registreren';

  @override
  String get continueWithGoogle => 'Doorgaan met Google';

  @override
  String get byContinuing => 'Door verder te gaan, gaat u akkoord met onze ';

  @override
  String get privacyPolicy => 'Privacybeleid';

  @override
  String get and => ' en ';

  @override
  String get termsAndConditions => 'Algemene voorwaarden';

  @override
  String get startPageSlogan => 'Waar taal leren en journalen samenkomen';

  @override
  String get signUp => 'Aanmelden';

  @override
  String get syncNotes => 'Synchroniseer uw notities op al uw apparaten';

  @override
  String get username => 'Gebruikersnaam';

  @override
  String get confirmPassword => 'Wachtwoord bevestigen';

  @override
  String get bySigningUp => 'Door u aan te melden, gaat u akkoord met onze ';

  @override
  String get alreadyHaveAnAccount => 'Heeft u al een account?';

  @override
  String get loginHere => ' Hier inloggen';

  @override
  String get receiveEmailResetPassword =>
      'Ontvang een e-mail om uw wachtwoord opnieuw in te stellen';

  @override
  String resendIn(Object secondsRemaining) {
    return 'Opnieuw verzenden over $secondsRemaining';
  }

  @override
  String get sendResetEmail => 'Wachtwoordherstel-e-mail verzenden';

  @override
  String get rememberYourPassword => 'Wachtwoord vergeten?';
}
