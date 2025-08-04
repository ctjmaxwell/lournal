// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get getStarted => 'Los geht\'s';

  @override
  String get login => 'Anmelden';

  @override
  String get welcomeBack => 'Willkommen zurück bei Lournal';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get dontHaveAnAccount => 'Noch kein Konto?';

  @override
  String get registerHere => ' Hier registrieren';

  @override
  String get continueWithGoogle => 'Mit Google fortfahren';

  @override
  String get byContinuing => 'Mit der Nutzung stimmen Sie unseren ';

  @override
  String get privacyPolicy => 'Datenschutzbestimmungen';

  @override
  String get and => ' und ';

  @override
  String get termsAndConditions => 'Allgemeinen Geschäftsbedingungen';

  @override
  String get startPageSlogan => 'Wo Sprachenlernen auf Journaling trifft';

  @override
  String get signUp => 'Registrieren';

  @override
  String get syncNotes => 'Synchronisieren Sie Ihre Notizen auf allen Geräten';

  @override
  String get username => 'Benutzername';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get bySigningUp => 'Mit der Registrierung stimmen Sie unseren ';

  @override
  String get alreadyHaveAnAccount => 'Sie haben bereits ein Konto?';

  @override
  String get loginHere => ' Hier anmelden';

  @override
  String get receiveEmailResetPassword =>
      'Erhalten Sie eine E-Mail, um Ihr Passwort zurückzusetzen';

  @override
  String resendIn(Object secondsRemaining) {
    return 'Erneut senden in $secondsRemaining';
  }

  @override
  String get sendResetEmail => 'E-Mail zum Zurücksetzen senden';

  @override
  String get rememberYourPassword => 'Passwort erinnert?';
}
