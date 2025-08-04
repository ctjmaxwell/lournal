// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get login => 'लॉग इन करें';

  @override
  String get welcomeBack => 'Lournal में आपका स्वागत है';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get dontHaveAnAccount => 'खाता नहीं है?';

  @override
  String get registerHere => ' यहां रजिस्टर करें';

  @override
  String get continueWithGoogle => 'Google के साथ जारी रखें';

  @override
  String get byContinuing => 'जारी रखकर, आप हमारी ';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get and => ' और ';

  @override
  String get termsAndConditions => 'नियम और शर्तें';

  @override
  String get startPageSlogan => 'जहां भाषा सीखना जर्नलिंग से मिलता है';

  @override
  String get signUp => 'साइन अप करें';

  @override
  String get syncNotes => 'अपने नोट्स को सभी डिवाइस पर सिंक करें';

  @override
  String get username => 'उपयोगकर्ता नाम';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get bySigningUp => 'साइन अप करके, आप हमारी ';

  @override
  String get alreadyHaveAnAccount => 'पहले से ही एक खाता है?';

  @override
  String get loginHere => ' यहां लॉग इन करें';

  @override
  String get receiveEmailResetPassword =>
      'अपना पासवर्ड रीसेट करने के लिए एक ईमेल प्राप्त करें';

  @override
  String resendIn(Object secondsRemaining) {
    return '$secondsRemaining में पुनः भेजें';
  }

  @override
  String get sendResetEmail => 'रीसेट ईमेल भेजें';

  @override
  String get rememberYourPassword => 'अपना पासवर्ड याद है?';
}
