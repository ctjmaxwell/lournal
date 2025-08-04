// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get getStarted => 'Empezar';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get welcomeBack => 'Bienvenido de nuevo a Lournal';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get dontHaveAnAccount => '¿No tienes una cuenta?';

  @override
  String get registerHere => ' Regístrate aquí';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get byContinuing => 'Al continuar, aceptas nuestra ';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get and => ' y ';

  @override
  String get termsAndConditions => 'Términos y Condiciones';

  @override
  String get startPageSlogan =>
      'Donde el aprendizaje de idiomas se une al diario';

  @override
  String get signUp => 'Regístrate';

  @override
  String get syncNotes => 'Sincroniza tus notas en todos tus dispositivos';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get bySigningUp => 'Al registrarte, aceptas nuestra ';

  @override
  String get alreadyHaveAnAccount => '¿Ya tienes una cuenta?';

  @override
  String get loginHere => ' Inicia sesión aquí';

  @override
  String get receiveEmailResetPassword =>
      'Recibe un correo electrónico para restablecer tu contraseña';

  @override
  String resendIn(Object secondsRemaining) {
    return 'Reenviar en $secondsRemaining';
  }

  @override
  String get sendResetEmail => 'Enviar correo de restablecimiento';

  @override
  String get rememberYourPassword => '¿Recuerdas tu contraseña?';
}
