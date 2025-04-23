import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/auth_provider.dart';
import '../../shared/widgets/custom_input.dart';
import '../../shared/widgets/primary_button.dart';

class LoginScreen extends ConsumerWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomInput(controller: _emailController, label: 'Email'),
            const SizedBox(height: 12),
            CustomInput(
              controller: _passwordController,
              label: 'Password',
              obscure: true,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Login',
              onPressed: () {
                ref.read(authProvider.notifier).state = true;
                context.go('/');
              },
            ),
            TextButton(
              onPressed: () => context.push('/signup'),
              child: const Text('Don’t have an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
