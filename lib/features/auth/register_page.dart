import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'register_security_page.dart';

import '../../core/theme/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: Stack(
          children: [
            Container(
              height: 300,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF3B35),
                    Color(0xFFED1C24),
                    Color(0xFFC81019),
                  ],
                ),
              ),
            ),

            Positioned(
              top: -70,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.09),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _GlassButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),

                        const Spacer(),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color:
                              Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Text(
                            '1 / 2',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'IBT ailesine\nhoş geldin.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 31,
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
                          color: Color(0xFFFFDADA),
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
                        24,
                        22,
                        25,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withValues(alpha: 0.075),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              _StepDot(active: true),
                              _StepLine(),
                              _StepDot(active: false),
                            ],
                          ),

                          const SizedBox(height: 22),

                          const Text(
                            'Kişisel Bilgiler',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'Bilgilerini eksiksiz ve doğru gir.',
                            style: TextStyle(
                              color: Color(0xFF858585),
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 25),

                          const _FieldTitle('Ad Soyad'),

                          const SizedBox(height: 8),

                          TextField(
                            textCapitalization:
                            TextCapitalization.words,
                            decoration: _inputDecoration(
                              hint: 'Adını ve soyadını gir',
                              icon: Icons.badge_outlined,
                            ),
                          ),

                          const SizedBox(height: 17),

                          const _FieldTitle(
                            'T.C. Kimlik Numarası',
                          ),

                          const SizedBox(height: 8),

                          TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            decoration: _inputDecoration(
                              hint: '11 haneli kimlik numaran',
                              icon:
                              Icons.account_box_outlined,
                            ),
                          ),

                          const SizedBox(height: 17),

                          const _FieldTitle('Telefon Numarası'),

                          const SizedBox(height: 8),

                          TextField(
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: _inputDecoration(
                              hint: '5XX XXX XX XX',
                              icon: Icons.phone_outlined,
                              prefixText: '+90  ',
                            ),
                          ),

                          const SizedBox(height: 17),

                          const _FieldTitle('E-posta'),

                          const SizedBox(height: 8),

                          TextField(
                            keyboardType:
                            TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              hint: 'ornek@email.com',
                              icon: Icons.mail_outline_rounded,
                            ),
                          ),

                          const SizedBox(height: 17),

                          const _FieldTitle('Şifre'),

                          const SizedBox(height: 8),

                          TextField(
                            obscureText: _obscurePassword,
                            decoration: _inputDecoration(
                              hint: 'Güçlü bir şifre oluştur',
                              icon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword =
                                    !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons
                                      .visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color:
                                  const Color(0xFF666666),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          InkWell(
                            borderRadius:
                            BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                _acceptedTerms =
                                !_acceptedTerms;
                              });
                            },
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: Checkbox(
                                      value: _acceptedTerms,
                                      activeColor:
                                      AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(5),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _acceptedTerms =
                                              value ?? false;
                                        });
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 11),

                                  const Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        style: TextStyle(
                                          color:
                                          Color(0xFF777777),
                                          fontSize: 11.5,
                                          height: 1.45,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                            'Kişisel verilerin işlenmesine ilişkin ',
                                          ),
                                          TextSpan(
                                            text:
                                            'aydınlatma metnini',
                                            style: TextStyle(
                                              color:
                                              AppColors.primary,
                                              fontWeight:
                                              FontWeight.w700,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                            ' okudum ve kabul ediyorum.',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _acceptedTerms
                                  ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const RegisterSecurityPage(),
                                  ),
                                );
                              }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor:
                                AppColors.primary,
                                disabledBackgroundColor:
                                const Color(0xFFFFC4C7),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Devam Et',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                      FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 9),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 19,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF8B8B8B),
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Bilgilerin IBT güvencesiyle korunur',
                          style: TextStyle(
                            color: Color(0xFF8B8B8B),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF8A8A8A),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF666666),
        size: 21,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFE8E8E8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.4,
        ),
      ),
    );
  }
}

class _FieldTitle extends StatelessWidget {
  final String text;

  const _FieldTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;

  const _StepDot({
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary
            : const Color(0xFFF1F1F1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        active
            ? Icons.check_rounded
            : Icons.circle_outlined,
        color: active
            ? Colors.white
            : const Color(0xFFB6B6B6),
        size: 15,
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        height: 2,
        color: const Color(0xFFEEEEEE),
      ),
    );
  }
}