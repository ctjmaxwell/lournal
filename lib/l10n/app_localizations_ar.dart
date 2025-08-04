// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get getStarted => 'البدء';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get welcomeBack => 'مرحبًا بك مرة أخرى في Lournal';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get dontHaveAnAccount => 'ليس لديك حساب؟';

  @override
  String get registerHere => ' سجل هنا';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام جوجل';

  @override
  String get byContinuing => 'باستمرارك، فإنك توافق على ';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get and => ' و ';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get startPageSlogan => 'حيث يلتقي تعلم اللغة بالتدوين';

  @override
  String get signUp => 'التسجيل';

  @override
  String get syncNotes => 'مزامنة ملاحظاتك عبر الأجهزة';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get bySigningUp => 'بتسجيلك، فإنك توافق على ';

  @override
  String get alreadyHaveAnAccount => 'هل لديك حساب بالفعل؟';

  @override
  String get loginHere => ' سجل الدخول هنا';

  @override
  String get receiveEmailResetPassword =>
      'تلقي رسالة بريد إلكتروني لإعادة تعيين كلمة المرور الخاصة بك';

  @override
  String resendIn(Object secondsRemaining) {
    return 'إعادة الإرسال في $secondsRemaining';
  }

  @override
  String get sendResetEmail => 'إرسال بريد إلكتروني لإعادة التعيين';

  @override
  String get rememberYourPassword => 'هل تذكر كلمة المرور الخاصة بك؟';
}
