// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get getStarted => 'Başla';

  @override
  String get login => 'Giriş Yap';

  @override
  String get welcomeBack => 'Lournal\'a tekrar hoş geldiniz';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get forgotPassword => 'Şifrenizi mi unuttunuz?';

  @override
  String get dontHaveAnAccount => 'Hesabınız yok mu?';

  @override
  String get registerHere => ' Buradan kaydolun';

  @override
  String get continueWithGoogle => 'Google ile devam et';

  @override
  String get byContinuing => 'Devam ederek, ';

  @override
  String get privacyPolicy => 'Gizlilik Politikamızı';

  @override
  String get and => ' ve ';

  @override
  String get termsAndConditions => 'Şartlar ve Koşullarımızı';

  @override
  String get startPageSlogan => 'Dil Öğrenimi Günlük Tutma ile Buluşuyor';

  @override
  String get signUp => 'Kaydol';

  @override
  String get syncNotes => 'Notlarınızı tüm cihazlarda senkronize edin';

  @override
  String get username => 'Kullanıcı Adı';

  @override
  String get confirmPassword => 'Şifreyi Onayla';

  @override
  String get bySigningUp => 'Kaydolarak, ';

  @override
  String get alreadyHaveAnAccount => 'Zaten bir hesabınız var mı?';

  @override
  String get loginHere => ' Buradan giriş yapın';

  @override
  String get receiveEmailResetPassword =>
      'Şifrenizi sıfırlamak için bir e-posta alın';

  @override
  String resendIn(Object secondsRemaining) {
    return '$secondsRemaining içinde tekrar gönder';
  }

  @override
  String get sendResetEmail => 'Sıfırlama E-postası Gönder';

  @override
  String get rememberYourPassword => 'Şifrenizi hatırlıyor musunuz?';
}
