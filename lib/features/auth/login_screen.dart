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

                if (response != null && response['error'] == null) {
                  final idToken = response['id_token'];
                  final accessToken = response['access_token'];
                  final decoded = JwtDecoder.decode(idToken);
                  final userId = response['technicianId'] ?? response['userId'];

                  final email = decoded['email'];
                  final role = decoded['custom:role'];
                  final firstName = response['firstname'] ?? '';
                  final lastName = response['lastname'] ?? '';
                  final mobile = response['mobile'] ?? '';

                  ref.read(authProvider.notifier).state = UserSession(
                    userId: userId,
                    email: email,
                    role: role,
                    idToken: idToken,
                    accessToken: accessToken,
                    firstName: firstName,
                    lastName: lastName,
                    mobile: mobile,
                  );

                  if (role == 'technician') {
                    context.go('/technician-home');
                  } else {
                    context.go('/');
                  }
                } else {
                  final message = response?['error'] ?? 'Login failed';
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
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
