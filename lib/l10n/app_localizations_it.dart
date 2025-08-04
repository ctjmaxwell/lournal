// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get getStarted => 'Inizia';

  @override
  String get login => 'Accedi';

  @override
  String get welcomeBack => 'Bentornato su Lournal';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get dontHaveAnAccount => 'Non hai un account?';

  @override
  String get registerHere => ' Registrati qui';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get byContinuing => 'Continuando, accetti la nostra ';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get and => ' e i nostri ';

  @override
  String get termsAndConditions => 'Termini e Condizioni';

  @override
  String get startPageSlogan =>
      'Dove l\'apprendimento delle lingue incontra il journaling';

  @override
  String get signUp => 'Registrati';

  @override
  String get syncNotes => 'Sincronizza le tue note su tutti i dispositivi';

  @override
  String get username => 'Nome utente';

  @override
  String get confirmPassword => 'Conferma password';

  @override
  String get bySigningUp => 'Registrandoti, accetti la nostra ';

  @override
  String get alreadyHaveAnAccount => 'Hai già un account?';

  @override
  String get loginHere => ' Accedi qui';

  @override
  String get receiveEmailResetPassword =>
      'Ricevi un\'email per reimpostare la tua password';

  @override
  String resendIn(Object secondsRemaining) {
    return 'Reinvia tra $secondsRemaining';
  }

  @override
  String get sendResetEmail => 'Invia email di reimpostazione';

  @override
  String get rememberYourPassword => 'Ricordi la tua password?';
}
