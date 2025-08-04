// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get getStarted => 'Начать';

  @override
  String get login => 'Войти';

  @override
  String get welcomeBack => 'С возвращением в Lournal';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get dontHaveAnAccount => 'Нет аккаунта?';

  @override
  String get registerHere => ' Зарегистрироваться здесь';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get byContinuing => 'Продолжая, вы соглашаетесь с нашей ';

  @override
  String get privacyPolicy => 'Политикой конфиденциальности';

  @override
  String get and => ' и ';

  @override
  String get termsAndConditions => 'Условиями использования';

  @override
  String get startPageSlogan =>
      'Где изучение языков встречается с ведением дневника';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get syncNotes => 'Синхронизируйте свои заметки на всех устройствах';

  @override
  String get username => 'Имя пользователя';

  @override
  String get confirmPassword => 'Подтвердить пароль';

  @override
  String get bySigningUp => 'Регистрируясь, вы соглашаетесь с нашей ';

  @override
  String get alreadyHaveAnAccount => 'Уже есть аккаунт?';

  @override
  String get loginHere => ' Войти здесь';

  @override
  String get receiveEmailResetPassword =>
      'Получите электронное письмо для сброса пароля';

  @override
  String resendIn(Object secondsRemaining) {
    return 'Повторная отправка через $secondsRemaining';
  }

  @override
  String get sendResetEmail => 'Отправить письмо для сброса';

  @override
  String get rememberYourPassword => 'Помните свой пароль?';
}
