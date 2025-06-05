import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lournal/auth/auth.dart';

Future<void> profileBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (_) => const FractionallySizedBox(
      heightFactor: 0.92,
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
        Navigator.pop(context);
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
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
              ],
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
        onPressed: () => _deleteAccount(context),
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
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    width: double.infinity,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondary,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      value ?? 'No $label available',
      style: const TextStyle(fontSize: 18),
    ),
  );
}

void _logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const AuthPage()),
  );
}

void _deleteAccount(BuildContext context) {
  // TODO: implement delete-account logic
}
