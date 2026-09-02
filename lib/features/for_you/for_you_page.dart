import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForYouPage extends StatelessWidget {
  const ForYouPage({super.key});

  static const Color navy = Color(0xFF102A43);
  static const Color teal = Color(0xFF0E7C86);
  static const Color background = Color(0xFFF4F6F8);
  static const Color text = Color(0xFF17212B);
  static const Color muted = Color(0xFF7C8793);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: navy),
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),

              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                  children: [
                    const _OfferCard(
                      icon: Icons.credit_card_rounded,
                      title: 'Kart fırsatları',
                      description:
                          'IBT Bank kartlarına özel avantajları keşfet.',
                      badge: 'Sana özel',
                    ),

                    const SizedBox(height: 14),

                    const Row(
                      children: [
                        Expanded(
                          child: _SmallOfferCard(
                            icon: Icons.directions_car_outlined,
                            title: 'Aracım',
                            description: 'Araç ihtiyaçlarını tek yerde yönet.',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _SmallOfferCard(
                            icon: Icons.home_outlined,
                            title: 'Evim',
                            description: 'Evine özel fırsatları keşfet.',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    const _OfferCard(
                      icon: Icons.flight_takeoff_rounded,
                      title: 'Seyahatim',
                      description:
                          'Seyahatin öncesi ve sonrası için fırsatlar.',
                      badge: 'Keşfet',
                    ),

                    const SizedBox(height: 22),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE7EAEE)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kampanyalar ve Programlar',
                            style: TextStyle(
                              color: text,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          SizedBox(height: 7),

                          Text(
                            'IBT Bank ayrıcalıkları ve sana özel kampanyalar burada olacak.',
                            style: TextStyle(
                              color: muted,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),

                          SizedBox(height: 20),

                          _CampaignPlaceholder(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: navy,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 25),
      child: const Text(
        'Senin İçin',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 23,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String badge;

  const _OfferCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EAEE)),
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3F4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: ForYouPage.teal, size: 31),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ForYouPage.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: const TextStyle(
                    color: ForYouPage.muted,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  badge,
                  style: const TextStyle(
                    color: ForYouPage.teal,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallOfferCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SmallOfferCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 185,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EAEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F3F4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: ForYouPage.teal),
          ),

          const Spacer(),

          Text(
            title,
            style: const TextStyle(
              color: ForYouPage.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            description,
            style: const TextStyle(
              color: ForYouPage.muted,
              fontSize: 11.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignPlaceholder extends StatelessWidget {
  const _CampaignPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF102A43), Color(0xFF174B5C)],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.auto_awesome_rounded, color: Colors.white),
          SizedBox(height: 10),
          Text(
            'IBT ayrıcalıkları',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Kampanyalar yakında burada.',
            style: TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
