import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class ConfirmSignupScreen extends StatefulWidget {
  final String email;
  final String role;

  const ConfirmSignupScreen({
    super.key,
    required this.email,
    required this.role,
  });

  @override
  State<ConfirmSignupScreen> createState() => _ConfirmSignupScreenState();
}

class _ConfirmSignupScreenState extends State<ConfirmSignupScreen> {
  late final TextEditingController _emailController;
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ Pre-fill email from widget
    _emailController = TextEditingController(text: widget.email);
  }

  void _confirmSignup() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final role = widget.role;

    final success = await AuthService.confirmSignup(email, code, role: role);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification successful. You can now login.'),
        ),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Signup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/signup?role=${widget.role}'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Verification Code'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmSignup,
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
