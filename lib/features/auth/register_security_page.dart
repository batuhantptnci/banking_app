import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import 'register_success_page.dart';

class RegisterSecurityPage extends StatefulWidget {
  const RegisterSecurityPage({super.key});

  @override
  State<RegisterSecurityPage> createState() =>
      _RegisterSecurityPageState();
}

class _RegisterSecurityPageState
    extends State<RegisterSecurityPage> {
  final TextEditingController _codeController =
  TextEditingController();

  bool _biometricEnabled = true;

  bool get _isCodeValid =>
      _codeController.text.length == 6;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
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
              right: -70,
              top: -80,
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
                          onTap: () =>
                              Navigator.pop(context),
                        ),

                        const Spacer(),

                        const _StepPill(),
                      ],
                    ),

                    const SizedBox(height: 28),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Son bir adım\nkaldı.',
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
                        'Hesabını güvence altına al ve IBT deneyimini başlat.',
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
                      padding: const EdgeInsets.all(22),
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
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const _ProgressHeader(),

                          const SizedBox(height: 26),

                          const Text(
                            'Telefonunu Doğrula',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Telefonuna gönderilen 6 haneli doğrulama kodunu gir.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 24),

                          TextField(
                            controller: _codeController,
                            keyboardType:
                            TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly,
                            ],
                            onChanged: (_) {
                              setState(() {});
                            },
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 13,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '000000',
                              hintStyle: const TextStyle(
                                color: Color(0xFFCBD1D6),
                                fontSize: 27,
                                letterSpacing: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              filled: true,
                              fillColor:
                              const Color(0xFFF7F9FA),
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(17),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(17),
                                borderSide:
                                const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              focusedBorder:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(17),
                                borderSide:
                                const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Kodu yeniden gönder',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Divider(
                            color: AppColors.border,
                          ),

                          const SizedBox(height: 15),

                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.softPrimary,
                              borderRadius:
                              BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration:
                                  const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.fingerprint_rounded,
                                    color: AppColors.primary,
                                    size: 27,
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
                                          color: AppColors
                                              .textPrimary,
                                          fontSize: 13.5,
                                          fontWeight:
                                          FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        'Sonraki girişlerini daha hızlı yap.',
                                        style: TextStyle(
                                          color: AppColors
                                              .textSecondary,
                                          fontSize: 11.5,
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
                                      _biometricEnabled =
                                          value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7F9),
                              borderRadius:
                              BorderRadius.circular(17),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Hesabın çok katmanlı güvenlik ve şifreli bağlantı ile korunacaktır.',
                                    style: TextStyle(
                                      color: AppColors
                                          .textSecondary,
                                      fontSize: 11.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isCodeValid
                                  ? () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const RegisterSuccessPage(),
                                  ),
                                );
                              }
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
                                    'Hesabımı Oluştur',
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

                    const SizedBox(height: 18),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'IBT güvenli doğrulama sistemi',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
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
  final VoidCallback onTap;

  const _GlassButton({
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
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill();

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
      child: const Text(
        '2 / 2',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
          ),
        ),

        Expanded(
          child: Container(
            height: 3,
            color: AppColors.primary,
          ),
        ),

        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Text(
            '2',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}