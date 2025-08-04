// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get getStarted => 'Começar';

  @override
  String get login => 'Entrar';

  @override
  String get welcomeBack => 'Bem-vindo de volta ao Lournal';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get forgotPassword => 'Esqueceu a senha?';

  @override
  String get dontHaveAnAccount => 'Não tem uma conta?';

  @override
  String get registerHere => ' Cadastre-se aqui';

  @override
  String get continueWithGoogle => 'Continuar com o Google';

  @override
  String get byContinuing => 'Ao continuar, você concorda com nossa ';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get and => ' e ';

  @override
  String get termsAndConditions => 'Termos e Condições';

  @override
  String get startPageSlogan =>
      'Onde o aprendizado de idiomas encontra o diário';

  @override
  String get signUp => 'Cadastrar';

  @override
  String get syncNotes => 'Sincronize suas notas em todos os dispositivos';

  @override
  String get username => 'Nome de usuário';

  @override
  String get confirmPassword => 'Confirmar senha';

  @override
  String get bySigningUp => 'Ao se cadastrar, você concorda com nossa ';

  @override
  String get alreadyHaveAnAccount => 'Já tem uma conta?';

  @override
  String get loginHere => ' Entrar aqui';

  @override
  String get receiveEmailResetPassword =>
      'Receba um e-mail para redefinir sua senha';

  @override
  String resendIn(Object secondsRemaining) {
    return 'Reenviar em $secondsRemaining';
  }

  @override
  String get sendResetEmail => 'Enviar e-mail de redefinição';

  @override
  String get rememberYourPassword => 'Lembra da sua senha?';
}
