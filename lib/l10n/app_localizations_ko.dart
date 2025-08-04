// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get getStarted => '시작하기';

  @override
  String get login => '로그인';

  @override
  String get welcomeBack => 'Lournal에 다시 오신 것을 환영합니다';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get dontHaveAnAccount => '계정이 없으신가요?';

  @override
  String get registerHere => ' 여기에서 등록하세요';

  @override
  String get continueWithGoogle => 'Google로 계속하기';

  @override
  String get byContinuing => '계속하면 당사의 ';

  @override
  String get privacyPolicy => '개인정보처리방침';

  @override
  String get and => ' 및 ';

  @override
  String get termsAndConditions => '이용약관';

  @override
  String get startPageSlogan => '언어 학습과 저널링의 만남';

  @override
  String get signUp => '가입';

  @override
  String get syncNotes => '모든 기기에서 메모 동기화';

  @override
  String get username => '사용자 이름';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get bySigningUp => '가입하면 당사의 ';

  @override
  String get alreadyHaveAnAccount => '이미 계정이 있으신가요?';

  @override
  String get loginHere => ' 여기에서 로그인하세요';

  @override
  String get receiveEmailResetPassword => '비밀번호 재설정 이메일 받기';

  @override
  String resendIn(Object secondsRemaining) {
    return '$secondsRemaining초 후 재전송';
  }

  @override
  String get sendResetEmail => '재설정 이메일 보내기';

  @override
  String get rememberYourPassword => '비밀번호를 기억하시나요?';
}
