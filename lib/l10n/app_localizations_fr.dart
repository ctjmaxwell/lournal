// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get getStarted => 'Commencer';

  @override
  String get login => 'Se connecter';

  @override
  String get welcomeBack => 'Bienvenue de nouveau sur Lournal';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get dontHaveAnAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get registerHere => ' S\'inscrire ici';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get byContinuing => 'En continuant, vous acceptez nos ';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get and => ' et nos ';

  @override
  String get termsAndConditions => 'Conditions générales';

  @override
  String get startPageSlogan =>
      'Où l\'apprentissage des langues rencontre le journalisme';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get syncNotes => 'Synchronisez vos notes sur tous les appareils';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get bySigningUp => 'En vous inscrivant, vous acceptez nos ';

  @override
  String get alreadyHaveAnAccount => 'Vous avez déjà un compte ?';

  @override
  String get loginHere => ' Se connecter ici';

  @override
  String get receiveEmailResetPassword =>
      'Recevez un e-mail pour réinitialiser votre mot de passe';

  @override
  String resendIn(Object secondsRemaining) {
    return 'Renvoyer dans $secondsRemaining';
  }

  @override
  String get sendResetEmail => 'Envoyer l\'e-mail de réinitialisation';

  @override
  String get rememberYourPassword =>
      'Vous vous souvenez de votre mot de passe ?';
}
