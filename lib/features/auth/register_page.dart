import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import 'register_security_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();

  final _tcController = TextEditingController();

  final _phoneController = TextEditingController();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _tcController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _continue() {
    final fullName = _nameController.text.trim();

    final nationalId = _tcController.text.trim();

    final phone = _phoneController.text.trim();

    final email = _emailController.text.trim();

    final password = _passwordController.text;

    if (fullName.length < 3) {
      _show('Ad soyad bilgisini gir.');
      return;
    }

    if (nationalId.length != 11) {
      _show('T.C. kimlik numarası 11 haneli olmalı.');
      return;
    }

    if (phone.length != 10 || !phone.startsWith('5')) {
      _show('Telefon numarası 5 ile başlayan 10 haneli bir numara olmalı.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _show('Geçerli bir e-posta adresi gir.');
      return;
    }

    if (password.length < 8) {
      _show('Şifre en az 8 karakter olmalı.');
      return;
    }

    if (!_acceptedTerms) {
      _show('Kullanım koşullarını kabul etmelisin.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterSecurityPage(
          fullName: fullName,
          nationalId: nationalId,
          phone: phone,
          email: email,
          password: password,
        ),
      ),
    );
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Container(
              height: 310,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.navy,
                    AppColors.navyLight,
                    Color(0xFF164A5A),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        _step('1 / 2'),
                      ],
                    ),
                    const SizedBox(height: 26),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'IBT Bank’e\nhoş geldin.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          height: 1.08,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kişisel Bilgiler',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _field(
                            title: 'Ad Soyad',
                            controller: _nameController,
                            icon: Icons.badge_outlined,
                            hint: 'Adını ve soyadını gir',
                            capitalization: TextCapitalization.words,
                          ),
                          _field(
                            title: 'T.C. Kimlik Numarası',
                            controller: _tcController,
                            icon: Icons.account_box_outlined,
                            hint: '11 haneli kimlik numaran',
                            keyboard: TextInputType.number,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                          ),
                          _field(
                            title: 'Telefon Numarası',
                            controller: _phoneController,
                            icon: Icons.phone_outlined,
                            hint: '5XX XXX XX XX',
                            prefix: '+90  ',
                            keyboard: TextInputType.phone,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                          _field(
                            title: 'E-posta',
                            controller: _emailController,
                            icon: Icons.mail_outline_rounded,
                            hint: 'ornek@email.com',
                            keyboard: TextInputType.emailAddress,
                          ),
                          const Text(
                            'Şifre',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: _input(
                              hint: 'En az 8 karakter',
                              icon: Icons.lock_outline_rounded,
                              suffix: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: AppColors.primary,
                            value: _acceptedTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptedTerms = value ?? false;
                              });
                            },
                            title: const Text(
                              'Kullanım koşullarını ve aydınlatma metnini okudum, kabul ediyorum.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _acceptedTerms ? _continue : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navy,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17),
                                ),
                              ),
                              child: const Text(
                                'Devam Et',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    String? prefix,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboard,
            inputFormatters: formatters,
            textCapitalization: capitalization,
            decoration: _input(hint: hint, icon: icon, prefix: prefix),
          ),
        ],
      ),
    );
  }
}

Widget _step(String value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Text(
      value,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    ),
  );
}

InputDecoration _input({
  required String hint,
  required IconData icon,
  Widget? suffix,
  String? prefix,
}) {
  return InputDecoration(
    hintText: hint,
    prefixText: prefix,
    prefixIcon: Icon(icon),
    suffixIcon: suffix,
    filled: true,
    fillColor: const Color(0xFFF7F9FA),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}
