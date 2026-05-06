import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_colors.dart';
import '../widgets/kawal_logo.dart';
import '../widgets/kawal_text_field.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ─── Form key & controllers ────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ─── UI state ─────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Auth handler — ready for Supabase integration ────────────────────────
  /// Replace the [Future.delayed] body with your Supabase auth call:
  ///   final response = await Supabase.instance.client.auth.signUp(
  ///     email: _emailController.text.trim(),
  ///     password: _passwordController.text,
  ///     data: {'full_name': _nameController.text.trim()},
  ///   );
  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'full_name': _nameController.text.trim()},
      );

      if (!mounted) return;

      // Navigate to Dashboard, clearing auth stack
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('Register Error: $e');
      setState(() => _errorMessage = 'Pendaftaran gagal: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // ── Logo ──────────────────────────────────────────────────
                const KawalLogo(size: 60),
                const SizedBox(height: 20),

                // ── Heading ───────────────────────────────────────────────
                const Text(
                  'Daftar Akun Baru',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Bergabung dengan Kawal TB untuk memantau\nkesehatan Anda dengan lebih mudah.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // ── Form ──────────────────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error banner
                      if (_errorMessage != null) ...[
                        _ErrorBanner(message: _errorMessage!),
                        const SizedBox(height: 16),
                      ],

                      // Full Name
                      KawalTextField(
                        controller: _nameController,
                        label: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap',
                        prefixIcon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Nama lengkap tidak boleh kosong';
                          if (v.trim().length < 3) return 'Nama minimal 3 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      KawalTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'contoh@email.com',
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
                        controller: _passwordController,
                        label: 'Kata Sandi',
                        hintText: 'Minimal 8 karakter',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Kata sandi tidak boleh kosong';
                          if (v.length < 8) return 'Kata sandi minimal 8 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      KawalTextField(
                        controller: _confirmPasswordController,
                        label: 'Ulangi Kata Sandi',
                        hintText: 'Ulangi kata sandi Anda',
                        prefixIcon: Icons.lock_reset_outlined,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                          ),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Konfirmasi kata sandi tidak boleh kosong';
                          if (v != _passwordController.text) return 'Kata sandi tidak cocok';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Register button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          child: _isLoading
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
                                    Text('Daftar'),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Terms text
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: 'Dengan mendaftar, Anda menyetujui '),
                            TextSpan(
                              text: 'Syarat & Ketentuan',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const TextSpan(text: ' serta '),
                            TextSpan(
                              text: 'Kebijakan Privasi',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const TextSpan(text: ' kami.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Login link ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Pop back to Login if in stack, otherwise push
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        }
                      },
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Private widgets ──────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
