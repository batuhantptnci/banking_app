import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'register_success_page.dart';

import '../../core/theme/app_colors.dart';

class RegisterSecurityPage extends StatefulWidget {
  const RegisterSecurityPage({super.key});

  @override
  State<RegisterSecurityPage> createState() =>
      _RegisterSecurityPageState();
}

class _RegisterSecurityPageState
    extends State<RegisterSecurityPage> {
  String _verificationCode = '';
  bool _biometricEnabled = true;

  bool get _isCodeValid => _verificationCode.length == 6;

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

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color:
                            Colors.white.withValues(alpha: 0.14),
                            borderRadius:
                            BorderRadius.circular(100),
                            border: Border.all(
                              color:
                              Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Text(
                            '2 / 2',
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
                        'Son bir adım\nkaldı.',
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
                        'Hesabını güvence altına al ve IBT deneyimini başlat.',
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
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              _CompletedStep(),
                              _StepLine(active: true),
                              _ActiveStep(),
                            ],
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            'Telefonunu Doğrula',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),

                          const SizedBox(height: 7),

                          const Text(
                            '05•• ••• •• 42 numaralı telefonuna gönderilen 6 haneli kodu gir.',
                            style: TextStyle(
                              color: Color(0xFF858585),
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 25),

                          TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _verificationCode = value;
                              });
                            },
                            style: const TextStyle(
                              fontSize: 24,
                              letterSpacing: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: '000000',
                              counterText: '',
                              hintStyle: const TextStyle(
                                fontSize: 24,
                                letterSpacing: 12,
                                color: Color(0xFFC5C5C5),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8F8F8),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE8E8E8),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 7),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Kodu yeniden gönder',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Divider(
                            color: Color(0xFFEEEEEE),
                          ),

                          const SizedBox(height: 15),

                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color:
                                  const Color(0xFFFFECEE),
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.fingerprint_rounded,
                                  color: AppColors.primary,
                                  size: 25,
                                ),
                              ),

                              const SizedBox(width: 13),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Biyometrik Giriş',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight.w700,
                                        color:
                                        AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Sonraki girişlerini daha hızlı yap.',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color:
                                        Color(0xFF858585),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Switch(
                                value: _biometricEnabled,
                                activeTrackColor:
                                AppColors.primary,
                                onChanged: (value) {
                                  setState(() {
                                    _biometricEnabled = value;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F8F8),
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                            child: const Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  color: AppColors.primary,
                                  size: 21,
                                ),

                                SizedBox(width: 11),

                                Expanded(
                                  child: Text(
                                    'Hesabın çok katmanlı güvenlik ve şifreli bağlantı ile korunacaktır.',
                                    style: TextStyle(
                                      color:
                                      Color(0xFF727272),
                                      fontSize: 11.5,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isCodeValid
                                  ? () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterSuccessPage(),
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
                                    'Hesabımı Oluştur',
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
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF8B8B8B),
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'IBT güvenli doğrulama sistemi',
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

class _CompletedStep extends StatelessWidget {
  const _CompletedStep();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}

class _ActiveStep extends StatelessWidget {
  const _ActiveStep();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '2',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;

  const _StepLine({
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        height: 2,
        color: active
            ? AppColors.primary
            : const Color(0xFFEEEEEE),
      ),
    );
  }
}