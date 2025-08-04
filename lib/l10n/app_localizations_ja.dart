// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get getStarted => '始める';

  @override
  String get login => 'ログイン';

  @override
  String get welcomeBack => 'Lournalへようこそ';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get dontHaveAnAccount => 'アカウントをお持ちではありませんか？';

  @override
  String get registerHere => ' ここで登録';

  @override
  String get continueWithGoogle => 'Googleで続行';

  @override
  String get byContinuing => '続行することにより、お客様は当社の ';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get and => ' および ';

  @override
  String get termsAndConditions => '利用規約';

  @override
  String get startPageSlogan => '言語学習とジャーナリングの出会い';

  @override
  String get signUp => '登録';

  @override
  String get syncNotes => 'すべてのデバイスでメモを同期する';

  @override
  String get username => 'ユーザー名';

  @override
  String get confirmPassword => 'パスワードを確認';

  @override
  String get bySigningUp => '登録することにより、お客様は当社の ';

  @override
  String get alreadyHaveAnAccount => 'すでにアカウントをお持ちですか？';

  @override
  String get loginHere => ' ここでログイン';

  @override
  String get receiveEmailResetPassword => 'パスワードをリセットするためのメールを受け取る';

  @override
  String resendIn(Object secondsRemaining) {
    return '$secondsRemaining秒後に再送信';
  }

  @override
  String get sendResetEmail => 'リセットメールを送信';

  @override
  String get rememberYourPassword => 'パスワードを覚えていますか？';
}
