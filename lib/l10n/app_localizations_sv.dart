// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get getStarted => 'Kom igång';

  @override
  String get login => 'Logga in';

  @override
  String get welcomeBack => 'Välkommen tillbaka till Lournal';

  @override
  String get email => 'E-post';

  @override
  String get password => 'Lösenord';

  @override
  String get forgotPassword => 'Glömt lösenord?';

  @override
  String get dontHaveAnAccount => 'Har du inget konto?';

  @override
  String get registerHere => ' Registrera dig här';

  @override
  String get continueWithGoogle => 'Fortsätt med Google';

  @override
  String get byContinuing => 'Genom att fortsätta godkänner du våra ';

  @override
  String get privacyPolicy => 'Integritetspolicy';

  @override
  String get and => ' och ';

  @override
  String get termsAndConditions => 'Allmänna villkor';

  @override
  String get startPageSlogan => 'Där språkinlärning möter journalföring';

  @override
  String get signUp => 'Registrera dig';

  @override
  String get syncNotes => 'Synkronisera dina anteckningar på alla enheter';

  @override
  String get username => 'Användarnamn';

  @override
  String get confirmPassword => 'Bekräfta lösenord';

  @override
  String get bySigningUp => 'Genom att registrera dig godkänner du våra ';

  @override
  String get alreadyHaveAnAccount => 'Har du redan ett konto?';

  @override
  String get loginHere => ' Logga in här';

  @override
  String get receiveEmailResetPassword =>
      'Få ett e-postmeddelande för att återställa ditt lösenord';

  @override
  String resendIn(Object secondsRemaining) {
    return 'Skicka igen om $secondsRemaining';
  }

  @override
  String get sendResetEmail => 'Skicka återställnings-e-post';

  @override
  String get rememberYourPassword => 'Kommer du ihåg ditt lösenord?';
}
