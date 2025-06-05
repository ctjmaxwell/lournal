import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lournal/auth/auth.dart';
import 'package:lournal/services/firestore.dart'; // Assuming this is your auth page

Future<void> profileBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (_) => const FractionallySizedBox(
      heightFactor: 1, // You might want to adjust this if the safe area makes it too tall
      child: _ProfileBottomSheetContent(),
    ),
  );
}

class _ProfileBottomSheetContent extends StatelessWidget {
  const _ProfileBottomSheetContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // If somehow unauthenticated, close the sheet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) { // Check if it's safe to pop
          Navigator.pop(context);
        }
      });
      return const SizedBox.shrink();
    }

    return _LoggedInProfile(user: user);
  }
}

class _LoggedInProfile extends StatelessWidget {
  final User user;

  const _LoggedInProfile({required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea( // Wrap the body with SafeArea
        top: true, // Ensure only top safe area is applied
        bottom: false, // Keep content extending to the bottom of the sheet
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // Consider adjusting maxHeight if SafeArea affects overall height significantly
              maxHeight: MediaQuery.of(context).size.height * 0.92,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _closeButton(context),
                  const SizedBox(height: 8),
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Username',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  _userContainer(context, 'username', user.displayName),
                  const SizedBox(height: 16),
                  const Text(
                    'Email Address',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  _userContainer(context, 'email', user.email),
                  const SizedBox(height: 16),
                  const Text(
                    'Account Settings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _accountActions(context),
                  // Add some padding at the bottom if needed, especially if bottom safe area was true
                  // const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _accountActions(BuildContext context) {
  return Column(
    children: [
      ElevatedButton(
        onPressed: () => _logout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: const Center(child: Text('Log Out')),
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () => _deleteAccount(context, FirebaseAuth.instance.currentUser),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: const Center(child: Text('Delete Account')),
      ),
    ],
  );
}

Widget _closeButton(BuildContext context) {
  return Row(
    children: [
      const Spacer(),
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
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

void _logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  // Ensure the context is still mounted before navigating
  if (Navigator.of(context).mounted) {
    Navigator.pushAndRemoveUntil( // More robust navigation after logout
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
      (route) => false, // Remove all previous routes
    );
  }
}

// MODIFIED _deleteAccount function in your UI file
void _deleteAccount(BuildContext context, User? currentUser) async { // Pass currentUser
  if (currentUser == null) {
    if (Navigator.of(context).mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in to delete.')),
      );
    }
    return;
  }
  final String userIdToDelete = currentUser.uid; // Get the ID to pass
  final firestoreService = FirestoreService();

  final bool? confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
            'This will permanently delete all your account data (notes, etc.). This action cannot be undone. Are you sure?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Forever'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

  // Optional: Show a loading dialog
  // showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

  try {
    await firestoreService.deleteUserAccountAndData(userIdToDelete: userIdToDelete);

    // If the function completes without error, it means either:
    // 1. Auth user was also deleted successfully.
    // 2. Auth user was not the one targeted (e.g. different UID passed, though here it's current user's UID)
    //    and Firestore data for 'userIdToDelete' was deleted.
    // For this specific UI flow (deleting one's own account), successful completion implies full deletion.
    if (Navigator.of(context).mounted) {
      // Pop loading dialog if shown
      // if (Navigator.of(context).canPop()) Navigator.of(context).pop(); // Pop the loading dialog first

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Account and all associated data deleted successfully.'),
            backgroundColor: Colors.green),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
        (route) => false,
      );
    }
  } on FirebaseAuthException catch (e) { // Catch specific exception from service
    // Pop loading dialog if shown
    // if (Navigator.of(context).mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();

    if (Navigator.of(context).mounted) {
      // The e.message will be the detailed one from FirestoreService
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.message ?? "Account data deleted, but an authentication issue occurred."),
            backgroundColor: Colors.orangeAccent, // Orange as it's a partial issue
            duration: const Duration(seconds: 8)), // Longer duration for user to read
      );
      // Even if re-auth is needed for the Auth record, their data is gone.
      // Navigate them to AuthPage as they are effectively logged out of their data.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
        (route) => false,
      );
    }
  } catch (e) { // Catch any other general exceptions from service
    // Pop loading dialog if shown
    // if (Navigator.of(context).mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();

    if (Navigator.of(context).mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("An error occurred: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8)),
      );
       // Navigate out as the account state is uncertain/problematic.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
        (route) => false,
      );
    }
  }
}