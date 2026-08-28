import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../home/home_page.dart';

import '../../core/theme/app_colors.dart';

class RegisterSuccessPage extends StatelessWidget {
  const RegisterSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // RED SUCCESS HERO
              Container(
                width: double.infinity,
                height: 410,
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
                child: Stack(
                  children: [
                    Positioned(
                      top: -75,
                      right: -65,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.09),
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
                              width: 94,
                              height: 94,
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.14,
                                    ),
                                    blurRadius: 28,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 46,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

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
                              'IBT Digital Banking dünyasına hoş geldin.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFFFDADA),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // CARD OVERLAP
              Transform.translate(
                offset: const Offset(0, -46),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const _InfoRow(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Dijital hesabın oluşturuldu',
                          subtitle:
                          'Hesaplarını ve bakiyeni tek ekrandan yönet.',
                        ),

                        const SizedBox(height: 20),

                        const _InfoRow(
                          icon: Icons.shield_outlined,
                          title: 'Güvenliğin aktif',
                          subtitle:
                          'Çok katmanlı güvenlik hesabını koruyor.',
                        ),

                        const SizedBox(height: 20),

                        const _InfoRow(
                          icon: Icons.bolt_rounded,
                          title: 'Her şey hazır',
                          subtitle:
                          'IBT bankacılık deneyimine başlayabilirsin.',
                        ),

                        const SizedBox(height: 26),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomePage(),
                                ),
                                    (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Bankacılığa Başla',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 9),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
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
                  'IBT  •  DIGITAL BANKING',
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.7,
                  ),
                ),
              ),

              const SizedBox(height: 12),
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFFECEE),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 23,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF858585),
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}