// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get getStarted => '开始';

  @override
  String get login => '登录';

  @override
  String get welcomeBack => '欢迎回到 Lournal';

  @override
  String get email => '电子邮件';

  @override
  String get password => '密码';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get dontHaveAnAccount => '没有账号？';

  @override
  String get registerHere => ' 在这里注册';

  @override
  String get continueWithGoogle => '使用 Google 继续';

  @override
  String get byContinuing => '继续即表示您同意我们的 ';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get and => ' 和 ';

  @override
  String get termsAndConditions => '条款和条件';

  @override
  String get startPageSlogan => '语言学习与日记的结合';

  @override
  String get signUp => '注册';

  @override
  String get syncNotes => '在设备之间同步您的笔记';

  @override
  String get username => '用户名';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get bySigningUp => '注册即表示您同意我们的 ';

  @override
  String get alreadyHaveAnAccount => '已有账号？';

  @override
  String get loginHere => ' 在这里登录';

  @override
  String get receiveEmailResetPassword => '接收电子邮件以重置您的密码';

  @override
  String resendIn(Object secondsRemaining) {
    return '在 $secondsRemaining 秒后重发';
  }

  @override
  String get sendResetEmail => '发送重置邮件';

  @override
  String get rememberYourPassword => '记住您的密码？';
}
