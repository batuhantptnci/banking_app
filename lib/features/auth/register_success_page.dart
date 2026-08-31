import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../home/home_page.dart';

class RegisterSuccessPage extends StatelessWidget {
  const RegisterSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 410,
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
                child: Stack(
                  children: [
                    Positioned(
                      top: -75,
                      right: -70,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                            Colors.white.withValues(
                              alpha: 0.06,
                            ),
                            width: 44,
                          ),
                        ),
                      ),
                    ),

                    SafeArea(
                      bottom: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 98,
                              height: 98,
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(
                                      alpha: 0.16,
                                    ),
                                    blurRadius: 28,
                                    offset:
                                    const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration:
                                const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            const Text(
                              'Hesabın hazır!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 31,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.7,
                              ),
                            ),

                            const SizedBox(height: 9),

                            const Text(
                              'IBT Bank dünyasına hoş geldin.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      22,
                      24,
                      22,
                      22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.black.withValues(
                            alpha: 0.075,
                          ),
                          blurRadius: 30,
                          offset:
                          const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const _InfoRow(
                          icon: Icons
                              .account_balance_wallet_outlined,
                          title:
                          'Dijital hesabın oluşturuldu',
                          subtitle:
                          'Hesaplarını ve bakiyeni tek ekrandan yönet.',
                        ),

                        const SizedBox(height: 21),

                        const _InfoRow(
                          icon: Icons.shield_outlined,
                          title: 'Güvenliğin aktif',
                          subtitle:
                          'IBT güvenlik sistemi hesabını koruyor.',
                        ),

                        const SizedBox(height: 21),

                        const _InfoRow(
                          icon: Icons.bolt_rounded,
                          title: 'Her şey hazır',
                          subtitle:
                          'Bankacılık deneyimine başlayabilirsin.',
                        ),

                        const SizedBox(height: 27),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const HomePage(),
                                ),
                                    (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                              AppColors.navy,
                              foregroundColor:
                              Colors.white,
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
                                  'Bankacılığa Başla',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 9),
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
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -20),
                child: const Text(
                  'IBT BANK  •  DIGITAL BANKING',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.softPrimary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}