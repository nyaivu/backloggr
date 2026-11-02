import 'package:flutter/material.dart';
import 'package:backloggr/data/repositories/auth_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Instantiate the Repository
  final AuthRepository _authRepo = AuthRepository();

  // 2. Create controllers to grab the text from the UI
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 3. State variable to show a loading spinner during network calls
  bool _isLoading = false;

  // Cleanup controllers when the screen is destroyed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIC FUNCTIONS ---

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      // Call the repository with the text from the controllers
      await _authRepo.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If successful, GoRouter's redirect guard (from main.dart)
      // will usually handle the routing automatically, but you can explicitly go home:
      if (mounted) context.go('/');
    } on AuthException catch (e) {
      // Supabase-specific errors (e.g., "Invalid login credentials")
      _showError(e.message);
    } catch (e) {
      // General errors
      _showError('An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);
    try {
      await _authRepo.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Note: If you have Supabase email confirmations turned ON,
      // they won't be able to log in immediately. They must click the email link.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        context.go('/');
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // --- UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Input
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
            ),
            const SizedBox(height: 16),

            // Password Input
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true, // Hides the password dots
            ),
            const SizedBox(height: 24),

            // Loading Spinner OR Action Buttons
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton(
                onPressed: _handleLogin,
                child: const Text('Login'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _handleRegister,
                child: const Text('Create Account'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
