import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lournal/components/custom_circular_progress_indicator.dart';
import 'package:lournal/components/my_textfield.dart';
import 'package:lournal/components/custom_snackbar.dart';
import 'package:lournal/providers/cooldown_service.dart'; // Import the service
import 'package:provider/provider.dart'; // Import provider

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  bool _emailHasError = false;
  bool _isSending = false; // Keep local state for the loading spinner

  // The local timer and state are NO LONGER NEEDED
  // int _secondsRemaining = 0;
  // Timer? _timer;
  // void _startCooldown() { ... }

  Future<void> sendPasswordResetEmail() async {
    _emailFocusNode.unfocus();
    
    // Get the service, but don't listen for changes here
    final cooldownService = Provider.of<CooldownService>(context, listen: false);

    // Check cooldown status from the service
    if (_isSending || cooldownService.isPasswordResetOnCooldown || !mounted) return;

    setState(() {
      _isSending = true;
      _emailHasError = false;
    });

    // The rest of your logic remains similar...
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(child: CustomCircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      
      if (mounted) Navigator.pop(context); // Pop loading circle
      // START THE COOLDOWN IN THE SERVICE
      if (mounted) {
        showCustomSnackBar(context, 'Password reset link sent! Please check your email.');
      }
      cooldownService.startPasswordResetCooldown();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        if (e.code == 'invalid-email') {
          setState(() { _emailHasError = true; });
          showCustomSnackBar(context, "The email address is badly formatted.", backgroundColor: Colors.red);
        } else if (e.code == 'too-many-requests') {
          showCustomSnackBar(context, 'Too many requests. Please try again later.', backgroundColor: Colors.red);
          // START THE COOLDOWN IN THE SERVICE
          cooldownService.startPasswordResetCooldown();
        } else {
          showCustomSnackBar(context, e.message ?? "An error occurred.", backgroundColor: Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showCustomSnackBar(context, "An unexpected error occurred.", backgroundColor: Colors.red);
      }
    } finally {
      if(mounted) {
        setState(() { _isSending = false; }); // Always stop the loading indicator
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    _emailFocusNode.dispose();
    // The timer is managed by the service, so no need to cancel it here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // WATCH the service here. This will make the widget rebuild when the timer ticks.
    final cooldownService = context.watch<CooldownService>();
    final bool isOnCooldown = cooldownService.isPasswordResetOnCooldown;
    final int secondsRemaining = cooldownService.passwordResetSecondsRemaining;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Forgot Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text('Receive an email to reset your password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
              const SizedBox(height: 25),
              MyTextField(
                hintText: "Email",
                obscureText: false,
                controller: emailController,
                hasError: _emailHasError,
                focusNode: _emailFocusNode,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => sendPasswordResetEmail(),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Use the values from the service to control the button
                  onPressed: _isSending || isOnCooldown ? null : sendPasswordResetEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOnCooldown ? Colors.grey.shade700 : Theme.of(context).colorScheme.tertiary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 36),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(
                    // And to display the correct text
                    isOnCooldown ? 'Resend in $secondsRemaining' : 'Send Reset Email',
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Remember your password?"),
                  GestureDetector(
                    onTap: () { Navigator.pop(context); },
                    child: Text(" Login", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.tertiary)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
