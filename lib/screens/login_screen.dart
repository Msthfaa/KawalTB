import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_colors.dart';
import '../screens/register_screen.dart';
import '../widgets/kawal_logo.dart';
import '../widgets/kawal_text_field.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Step 1: Sign in with Supabase Auth
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Step 2: Navigate to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: ${e.message}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.paddingOf(context).vertical,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.06),

                  // ── Logo & brand ──────────────────────────────────────────
                  const KawalLogo(size: 68),
                  const SizedBox(height: 14),
                  const Text(
                    'Kawal TB',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pantau pengobatan Anda setiap hari',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: size.height * 0.05),

                  // ── Card ──────────────────────────────────────────────────
                  _LoginCard(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    isLoading: _isLoading,
                    obscurePassword: _obscurePassword,
                    rememberMe: _rememberMe,
                    onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                    onToggleRemember: (v) => setState(() => _rememberMe = v ?? false),
                    onForgotPassword: () {
                      // TODO: Navigate to forgot-password screen
                    },
                    onLogin: _handleLogin,
                  ),

                  const SizedBox(height: 28),

                  // ── Divider + Google ──────────────────────────────────────
                  _OrDivider(),
                  const SizedBox(height: 16),
                  _GoogleButton(),
                  const SizedBox(height: 32),

                  // ── Register link ─────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        ),
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Private sub-widgets ──────────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onTogglePassword,
    required this.onToggleRemember,
    required this.onForgotPassword,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool obscurePassword;
  final bool rememberMe;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onToggleRemember;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.shadowDeep,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Datang Kembali',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Email
            KawalTextField(
              controller: emailController,
              label: 'Email',
              hintText: 'Masukkan email Anda',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(v)) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password
            KawalTextField(
              controller: passwordController,
              label: 'Kata Sandi',
              hintText: 'Masukkan kata sandi',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                ),
                onPressed: onTogglePassword,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Kata sandi tidak boleh kosong';
                if (v.length < 6) return 'Kata sandi minimal 6 karakter';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Remember me + Forgot password
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: rememberMe,
                    onChanged: onToggleRemember,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Ingat Saya',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onForgotPassword,
                  child: const Text(
                    'Lupa Kata Sandi?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Login button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onLogin,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Masuk'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // TODO: Supabase Google OAuth sign-in
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: const Text(
                'G',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Masuk dengan Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
