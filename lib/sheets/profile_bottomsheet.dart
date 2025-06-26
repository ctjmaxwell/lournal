import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lournal/auth/auth.dart'; // Assuming this is your auth page
import 'package:lournal/services/firestore.dart'; // Your FirestoreService
import 'package:lournal/components/custom_snackbar.dart'; // Your custom snackbar
import 'package:lournal/components/my_textfield.dart'; // Import your custom text field

/// Shows a modal bottom sheet with the user's profile information and actions.
Future<void> profileBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (_) => const _ProfileBottomSheetContent(),
  );
}

class _ProfileBottomSheetContent extends StatelessWidget {
  const _ProfileBottomSheetContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return const SizedBox.shrink();
    }

    return _LoggedInProfile(user: user);
  }
}

class _LoggedInProfile extends StatefulWidget {
  final User user;
  const _LoggedInProfile({required this.user, Key? key}) : super(key: key);

  @override
  State<_LoggedInProfile> createState() => _LoggedInProfileState();
}

class _LoggedInProfileState extends State<_LoggedInProfile> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _reAuthPasswordController =
      TextEditingController();
  
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  // --- REMOVED: Error message state variable is no longer needed ---

  @override
  void dispose() {
    _reAuthPasswordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Handles the primary account deletion attempt
  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.deleteUserAccount();

      if (mounted) {
        showCustomSnackBar(
            context, 'Account and all associated data deleted successfully.');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (e.code == 'requires-recent-login') {
        _showReAuthDialog();
      } else {
        showCustomSnackBar(context, 'Error deleting account: ${e.message}',
            backgroundColor: Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showCustomSnackBar(context, 'An unexpected error occurred: $e',
          backgroundColor: Colors.red);
    }
  }

  // Shows a dialog for re-authentication with only the password field
  Future<void> _showReAuthDialog() async {
    _reAuthPasswordController.clear();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) { // We use this dialogContext now
        void performReAuth() {
          if (Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
          _reauthenticateAndRetryDelete();
        }

        // Request focus for the password field after the dialog has been built.
        WidgetsBinding.instance.addPostFrameCallback((_) {
            FocusScope.of(dialogContext).requestFocus(_passwordFocusNode);
        });

        return Dialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Re-authenticate',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text(
                    'This is a sensitive action. For your security, please confirm your password to proceed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  MyTextField(
                    controller: _reAuthPasswordController,
                    hintText: 'Password',
                    obscureText: true,
                    focusNode: _passwordFocusNode,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => performReAuth(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.inversePrimary),
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          setState(() {
                            _isLoading = false;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white),
                        onPressed: performReAuth,
                        child: const Text('Confirm & Delete',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Re-authenticates the user using the user's current email
  Future<void> _reauthenticateAndRetryDelete() async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      setState(() {
        _isLoading = false;
      });
      if(mounted) {
        showCustomSnackBar(context, "Could not find a user or email to re-authenticate.", backgroundColor: Colors.red);
      }
      return;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _reAuthPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);
      await _deleteAccount(); 
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      // --- MODIFIED: Show snackbar directly, don't set state ---
      showCustomSnackBar(context, 'Re-authentication failed: ${e.message}', backgroundColor: Colors.red);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      // --- MODIFIED: Show snackbar directly, don't set state ---
      showCustomSnackBar(context, 'An unexpected error occurred during re-authentication: $e', backgroundColor: Colors.red);
    }
  }

  // Wrapper function to show confirmation dialog before calling _deleteAccount
  Future<void> _confirmAndDeleteAccount(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Delete Account?',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text(
                    'This will permanently delete your account and all associated data. This action cannot be undone. Are you sure?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.inversePrimary),
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white),
                      child: const Text('Delete Forever',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  void _logout() async { // No BuildContext parameter needed here, as 'context' is accessible from the State
    await FirebaseAuth.instance.signOut();

    // Check if the State object is still mounted before using its context
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil( // Use Navigator.of(context)
        MaterialPageRoute(builder: (_) => const AuthPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _closeButton(context),
              const SizedBox(height: 8),
              const Text('Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Username',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _userContainer(context, 'username', widget.user.displayName),
              const SizedBox(height: 16),
              const Text('Email Address',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _userContainer(context, 'email', widget.user.email),
              const SizedBox(height: 16),
              const Text('Account Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _accountActions(context),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              // --- REMOVED: Error message text widget ---
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountActions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _logout(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: const Center(child: Text('Log Out')),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed:
              _isLoading ? null : () => _confirmAndDeleteAccount(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                )
              : const Center(child: Text('Delete Account')),
        ),
      ],
    );
  }

  Widget _closeButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            color: Theme.of(context).colorScheme.inversePrimary,
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _userContainer(BuildContext context, String label, String? value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value ?? 'No $label available',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
