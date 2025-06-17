import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lournal/auth/auth.dart'; // Assuming this is your auth page
import 'package:lournal/services/firestore.dart'; // Your FirestoreService

/// Shows a modal bottom sheet with the user's profile information and actions.
Future<void> profileBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    // Allows the sheet to be scrollable and take up the full screen.
    isScrollControlled: true,
    // This is the key change: it ensures the bottom sheet respects the
    // device's safe areas (like the status bar and navigation bar).
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    clipBehavior: Clip.antiAlias,
    // The FractionallySizedBox was removed to allow the content to size itself
    // correctly within the safe area.
    builder: (_) => const _ProfileBottomSheetContent(),
  );
}

class _ProfileBottomSheetContent extends StatelessWidget {
  const _ProfileBottomSheetContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // If for some reason the user is null, close the sheet.
    if (user == null) {
      // Schedule a post-frame callback to pop the navigator safely.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return const SizedBox.shrink(); // Return an empty widget if no user
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
  final TextEditingController _reAuthEmailController = TextEditingController();
  final TextEditingController _reAuthPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reAuthEmailController.dispose();
    _reAuthPasswordController.dispose();
    super.dispose();
  }

  // Handles the primary account deletion attempt
  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _firestoreService.deleteUserAccount();

      print('Firebase Auth user and associated data deleted successfully!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account and all associated data deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to AuthPage and clear navigation stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false; // Stop loading on error
      });

      if (e.code == 'requires-recent-login') {
        _showReAuthDialog(); // Prompt for re-authentication
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false; // Stop loading on error
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
      print('An unexpected error occurred during account deletion: $e');
    }
  }

  // Shows a dialog for re-authentication
  Future<void> _showReAuthDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Re-authenticate to Delete Account'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                    'For security, please re-enter your credentials to confirm.'),
                TextField(
                  controller: _reAuthEmailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _reAuthPasswordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _isLoading = false; // Stop loading if cancelled
                  _errorMessage = "Account deletion cancelled.";
                });
              },
            ),
            ElevatedButton(
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Text('Re-authenticate & Delete'),
              onPressed: _isLoading ? null : () async {
                Navigator.of(dialogContext).pop(); // Close the dialog
                await _reauthenticateAndRetryDelete();
              },
            ),
          ],
        );
      },
    );
  }

  // Re-authenticates the user and then retries the deletion
  Future<void> _reauthenticateAndRetryDelete() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = "No user is currently signed in.";
        _isLoading = false;
      });
      return;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: _reAuthEmailController.text.trim(),
        password: _reAuthPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);
      print('User re-authenticated successfully. Retrying deletion...');
      // If re-authentication is successful, call _deleteAccount again.
      await _deleteAccount();
    } on FirebaseAuthException catch (e) {
       if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Re-authentication failed: ${e.message}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
       if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred during re-authentication: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Delete Account?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                const Text('This will permanently delete your account and all associated data. This action cannot be undone. Are you sure?', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      style: TextButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      child: const Text('Delete Forever', style: TextStyle(fontWeight: FontWeight.bold)),
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
      await _deleteAccount(); // Proceed with deletion if confirmed
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
        (route) => false,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // This Scaffold provides the main structure inside the bottom sheet.
    // The SafeArea widget is no longer needed here because `useSafeArea: true`
    // is now set on the showModalBottomSheet itself.
    return Scaffold(
      // The background color is transparent so the rounded corners of the sheet are visible.
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Padding(
          // Padding is added to keep content from touching the screen edges.
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // The `mainAxisSize: MainAxisSize.min` is removed so the Column
            // can fill the available vertical space, which is controlled by SingleChildScrollView.
            children: [
              _closeButton(context),
              const SizedBox(height: 8),
              const Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Username', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _userContainer(context, 'username', widget.user.displayName),
              const SizedBox(height: 16),
              const Text('Email Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _userContainer(context, 'email', widget.user.email),
              const SizedBox(height: 16),
              const Text('Account Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _accountActions(context),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
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
          onPressed: () => _logout(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: const Center(child: Text('Log Out')),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _confirmAndDeleteAccount(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
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