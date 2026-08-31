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
    if (_nameController.text.trim().isEmpty ||
        _tcController.text.length != 11 ||
        _phoneController.text.length != 10 ||
        !_emailController.text.contains('@') ||
        _passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Lütfen bilgilerini eksiksiz ve doğru doldur.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterSecurityPage(),
      ),
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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.navy,
                    AppColors.navyLight,
                    Color(0xFF164A5A),
                  ],
                ),
              ),
            ),

            Positioned(
              top: -80,
              right: -70,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                    width: 40,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  30,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _GlassButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),

                        const Spacer(),

                        const _StepPill(
                          text: '1 / 2',
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'IBT Bank’e\nhoş geldin.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          height: 1.08,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Birkaç bilgiyle dijital bankacılık deneyimini başlat.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        22,
                        23,
                        22,
                        25,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _ProgressHeader(
                            secondActive: false,
                          ),

                          const SizedBox(height: 25),

                          const Text(
                            'Kişisel Bilgiler',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'Bilgilerini eksiksiz ve doğru gir.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 25),

                          _field(
                            title: 'Ad Soyad',
                            controller: _nameController,
                            hint: 'Adını ve soyadını gir',
                            icon: Icons.badge_outlined,
                            capitalization:
                            TextCapitalization.words,
                          ),

                          _field(
                            title: 'T.C. Kimlik Numarası',
                            controller: _tcController,
                            hint: '11 haneli kimlik numaran',
                            icon: Icons.account_box_outlined,
                            keyboard: TextInputType.number,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                          ),

                          _field(
                            title: 'Telefon Numarası',
                            controller: _phoneController,
                            hint: '5XX XXX XX XX',
                            icon: Icons.phone_outlined,
                            keyboard: TextInputType.phone,
                            prefixText: '+90  ',
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),

                          _field(
                            title: 'E-posta',
                            controller: _emailController,
                            hint: 'ornek@email.com',
                            icon: Icons.mail_outline_rounded,
                            keyboard:
                            TextInputType.emailAddress,
                          ),

                          const Text(
                            'Şifre',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: _inputDecoration(
                              hint: 'Güçlü bir şifre oluştur',
                              icon: Icons.lock_outline_rounded,
                              suffix: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword =
                                    !_obscurePassword;
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

                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setState(() {
                                _acceptedTerms =
                                !_acceptedTerms;
                              });
                            },
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _acceptedTerms,
                                  activeColor:
                                  AppColors.primary,
                                  onChanged: (value) {
                                    setState(() {
                                      _acceptedTerms =
                                          value ?? false;
                                    });
                                  },
                                ),

                                const SizedBox(width: 4),

                                const Expanded(
                                  child: Padding(
                                    padding:
                                    EdgeInsets.only(top: 11),
                                    child: Text(
                                      'Kullanım koşullarını ve aydınlatma metnini okudum, kabul ediyorum.',
                                      style: TextStyle(
                                        color: AppColors
                                            .textSecondary,
                                        fontSize: 11.5,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed:
                              _acceptedTerms
                                  ? _continue
                                  : null,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor:
                                AppColors.navy,
                                foregroundColor:
                                Colors.white,
                                disabledBackgroundColor:
                                const Color(0xFFD8DEE3),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(17),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Devam Et',
                                    style: TextStyle(
                                      fontWeight:
                                      FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                  ),
                                ],
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
    required String hint,
    required IconData icon,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    String? prefixText,
    TextCapitalization capitalization =
        TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: controller,
            keyboardType: keyboard,
            inputFormatters: formatters,
            textCapitalization: capitalization,
            decoration: _inputDecoration(
              hint: hint,
              icon: icon,
              prefixText: prefixText,
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String hint,
  required IconData icon,
  Widget? suffix,
  String? prefixText,
}) {
  return InputDecoration(
    hintText: hint,
    prefixText: prefixText,
    suffixIcon: suffix,
    prefixIcon: Icon(
      icon,
      color: AppColors.textSecondary,
    ),
    filled: true,
    fillColor: const Color(0xFFF7F9FA),
    hintStyle: const TextStyle(
      color: Color(0xFFA1A9B1),
      fontSize: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: AppColors.border,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1.5,
      ),
    ),
  );
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  final String text;

  const _StepPill({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final bool secondActive;

  const _ProgressHeader({
    required this.secondActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(
          active: true,
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),

        Expanded(
          child: Container(
            height: 3,
            color: secondActive
                ? AppColors.primary
                : AppColors.border,
          ),
        ),

        _dot(
          active: secondActive,
          child: Text(
            '2',
            style: TextStyle(
              color: secondActive
                  ? Colors.white
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dot({
    required bool active,
    required Widget child,
  }) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary
            : const Color(0xFFF0F3F5),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}