import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/auth_provider.dart';
import '../../shared/widgets/custom_input.dart';
import '../../shared/widgets/primary_button.dart';
import '../../services/auth_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../state/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'user'; // or 'technician'

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(value: 'user', child: Text('User')),
                DropdownMenuItem(
                  value: 'technician',
                  child: Text('Technician'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Login',
              onPressed: () async {
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();

                final response = await AuthService.login(
                  email,
                  password,
                  _selectedRole,
                );

                if (response != null) {
                  final idToken = response['id_token'];
                  final accessToken = response['access_token'];
                  final decoded = JwtDecoder.decode(idToken);
                  final userId = response['technicianId'] ?? response['userId'];

                  print("UserId :  $userId");
                  final email = decoded['email'];
                  final role = decoded['custom:role'];

                  ref.read(authProvider.notifier).state = UserSession(
                    userId: userId,
                    email: email,
                    role: role,
                    idToken: idToken,
                    accessToken: accessToken,
                  );

                  if (role == 'technician') {
                    context.go('/technician-home');
                  } else {
                    context.go('/');
                  }
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Login failed')));
                }
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
