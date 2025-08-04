// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get getStarted => 'Anza';

  @override
  String get login => 'Ingia';

  @override
  String get welcomeBack => 'Karibu tena Lournal';

  @override
  String get email => 'Barua pepe';

  @override
  String get password => 'Nenosiri';

  @override
  String get forgotPassword => 'Umesahau nenosiri?';

  @override
  String get dontHaveAnAccount => 'Huna akaunti?';

  @override
  String get registerHere => ' Jisajili hapa';

  @override
  String get continueWithGoogle => 'Endelea na Google';

  @override
  String get byContinuing => 'Kwa kuendelea, unakubali ';

  @override
  String get privacyPolicy => 'Sera yetu ya Faragha';

  @override
  String get and => ' na ';

  @override
  String get termsAndConditions => 'Masharti na Vigezo';

  @override
  String get startPageSlogan =>
      'Ambapo Kujifunza Lugha Kunakutana na Kuandika Jarida';

  @override
  String get signUp => 'Jisajili';

  @override
  String get syncNotes => 'Sawazisha madokezo yako kwenye vifaa vyote';

  @override
  String get username => 'Jina la mtumiaji';

  @override
  String get confirmPassword => 'Thibitisha Nenosiri';

  @override
  String get bySigningUp => 'Kwa kujisajili, unakubali ';

  @override
  String get alreadyHaveAnAccount => 'Tayari una akaunti?';

  @override
  String get loginHere => ' Ingia hapa';

  @override
  String get receiveEmailResetPassword =>
      'Pokea barua pepe ili kuweka upya nenosiri lako';

  @override
  String resendIn(Object secondsRemaining) {
    return 'Tuma tena baada ya $secondsRemaining';
  }

  @override
  String get sendResetEmail => 'Tuma Barua pepe ya Kuweka Upya';

  @override
  String get rememberYourPassword => 'Unakumbuka nenosiri lako?';
}
