import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:banking_app/services/api_service.dart';
import 'package:banking_app/models/account_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();

  final List<GlobalKey> _tabKeys = List.generate(
    5,
        (_) => GlobalKey(),
  );

  static const Color background = Color(0xFFF4F6F8);
  static const Color navy = Color(0xFF102A43);
  static const Color teal = Color(0xFF0E7C86);
  static const Color text = Color(0xFF17212B);
  static const Color muted = Color(0xFF7C8793);
  static const String bankName = 'IBT Bank';

  final List<String> tabs = const [
    'Genel Bakış',
    'Hesaplar',
    'Kartlar',
    'Yatırımlar',
    'Krediler',
  ];

  int selectedTab = 0;
  List<AccountModel> _accounts = [];
  bool _accountsLoading = true;
  String? _accountsError;

  double get _totalBalance {
    return _accounts.fold(
      0,
          (total, account) => total + account.balance,
    );
  }
  String _formatWhole(double value) {
    final whole = value.floor().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(whole[i]);
    }

    return buffer.toString();
  }

  String _formatDecimal(double value) {
    final fixed = value.toStringAsFixed(2);
    final decimal = fixed.split('.')[1];

    return ',$decimal TL';
  }

  String _formatMoney(double value) {
    return '${_formatWhole(value)}${_formatDecimal(value)}';
  }
  Color get sectionColor {
    switch (selectedTab) {
      case 1:
        return const Color(0xFF123D5A);
      case 2:
        return const Color(0xFF116A70);
      case 3:
        return const Color(0xFF2E303B);
      case 4:
        return const Color(0xFF4B426B);
      default:
        return navy;
    }
  }

  String get searchHint {
    switch (selectedTab) {
      case 1:
        return 'Hesap veya işlem ara';
      case 2:
        return 'Kart veya işlem ara';
      case 3:
        return 'Yatırım ürünü veya işlemi ara';
      case 4:
        return 'Kredi ürünü veya işlemi ara';
      default:
        return 'Ürün, hesap veya işlem ara';
    }
  }
  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await ApiService.getMyAccounts();

      if (!mounted) return;

      setState(() {
        _accounts = accounts;
        _accountsLoading = false;
        _accountsError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _accountsLoading = false;
        _accountsError = e.toString();
      });
    }
  }
  @override
  void dispose() {
    _scrollController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: sectionColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: sectionColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),

              // SABİT SEKME MENÜSÜ
              _buildTabs(),

              // SADECE BURASI SCROLL
              Expanded(
                child: ColoredBox(
                  color: background,
                  child: ListView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      _buildHero(),

                      Transform.translate(
                        offset: const Offset(0, -22),
                        child: Column(
                          children: [
                            _buildSearchBar(),
                            const SizedBox(height: 26),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildSelectedContent(),
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
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: sectionColor,
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.70),
                width: 1.4,
              ),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İyi günler Batuhan,',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'IBT Bank',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              try {
                final message = await ApiService.getHello();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                  ),
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bağlantı hatası: $e'),
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TABS
  // ---------------------------------------------------------------------------

  Widget _buildTabs() {
    return Container(
      height: 68,
      color: sectionColor,
      child: ListView.builder(
        controller: _tabScrollController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final selected = index == selectedTab;

          return GestureDetector(
            key: _tabKeys[index],
            onTap: () {
              if (selectedTab == index) return;

              setState(() {
                selectedTab = index;
              });

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;

                // Yeni sekmenin sayfasını en üste getir.
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(0);
                }

                // Seçilen üst sekmeyi görünür alana / merkeze getir.
                final tabContext = _tabKeys[index].currentContext;

                if (tabContext != null) {
                  Scrollable.ensureVisible(
                    tabContext,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    alignment: 0.5,
                  );
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 190),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HERO
  // ---------------------------------------------------------------------------

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      color: sectionColor,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 54),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(selectedTab),
          child: _heroForCurrentTab(),
        ),
      ),
    );
  }

  Widget _heroForCurrentTab() {
    switch (selectedTab) {
      case 1:
        return _heroContent(
          eyebrow: 'TOPLAM BAKİYE',
          amount: _accountsLoading
              ? '—'
              : _formatWhole(_totalBalance),
          decimal: _accountsLoading
              ? ''
              : _formatDecimal(_totalBalance),
          selector: 'Vadesiz TL hesaplar',
          selectorIcon: Icons.account_balance_wallet_outlined,
          actions: const [
            _QuickActionData(
              Icons.add_circle_outline,
              'Hesap\nAç / Ekle',
            ),
            _QuickActionData(
              Icons.savings_outlined,
              'Para\nYatır',
            ),
            _QuickActionData(
              Icons.qr_code_2_rounded,
              'QR ile\nİşlem',
            ),
            _QuickActionData(
              Icons.more_horiz_rounded,
              'Diğer\nİşlemler',
            ),
          ],
        );

      case 2:
        return _heroContent(
          eyebrow: 'KULLANILABİLİR LİMİT',
          amount: '49.255',
          decimal: ',46 TL',
          selector: 'Premium Card •••• 8926',
          selectorIcon: Icons.credit_card_rounded,
          actions: const [
            _QuickActionData(
              Icons.add_card_rounded,
              'Karta\nBaşvur',
            ),
            _QuickActionData(
              Icons.trending_up_rounded,
              'Limit\nArtır',
            ),
            _QuickActionData(
              Icons.payments_outlined,
              'Ödeme\nYap',
            ),
            _QuickActionData(
              Icons.more_horiz_rounded,
              'Diğer\nİşlemler',
            ),
          ],
        );

      case 3:
        return _heroContent(
          eyebrow: 'GÜNCEL YATIRIM BAKİYESİ',
          amount: '165',
          decimal: ',63 TL',
          selector: 'Portföyüm',
          selectorIcon: Icons.show_chart_rounded,
          actions: const [
            _QuickActionData(
              Icons.candlestick_chart_rounded,
              'Hisse\nAl / Sat',
            ),
            _QuickActionData(
              Icons.filter_alt_outlined,
              'Fon\nAl / Sat',
            ),
            _QuickActionData(
              Icons.currency_exchange_rounded,
              'Döviz\nAl / Sat',
            ),
            _QuickActionData(
              Icons.query_stats_rounded,
              'Yatırım\nİşlemleri',
            ),
          ],
        );

      case 4:
        return _heroContent(
          eyebrow: 'TOPLAM KREDİ BORCU',
          amount: '24.850',
          decimal: ',00 TL',
          selector: 'İhtiyaç Kredisi',
          selectorIcon: Icons.account_balance_outlined,
          actions: const [
            _QuickActionData(
              Icons.add_circle_outline,
              'Krediye\nBaşvur',
            ),
            _QuickActionData(
              Icons.calculate_outlined,
              'Kredi\nHesapla',
            ),
            _QuickActionData(
              Icons.calendar_month_outlined,
              'Ödeme\nPlanı',
            ),
            _QuickActionData(
              Icons.more_horiz_rounded,
              'Diğer\nİşlemler',
            ),
          ],
        );

      default:
        return _heroContent(
          eyebrow: 'TOPLAM VARLIĞIM',
          amount: _accountsLoading
              ? '—'
              : _formatWhole(_totalBalance),
          decimal: _accountsLoading
              ? ''
              : _formatDecimal(_totalBalance),
          selector: 'Tüm varlıklarım',
          selectorIcon: Icons.account_balance_rounded,
          actions: const [
            _QuickActionData(
              Icons.swap_horiz_rounded,
              'Para\nTransferi',
            ),
            _QuickActionData(
              Icons.qr_code_2_rounded,
              'QR ile\nİşlem',
            ),
            _QuickActionData(
              Icons.receipt_long_outlined,
              'Ödeme\nYap',
            ),
            _QuickActionData(
              Icons.grid_view_rounded,
              'Tüm\nİşlemler',
            ),
          ],
        );
    }
  }

  Widget _heroContent({
    required String eyebrow,
    required String amount,
    required String decimal,
    required String selector,
    required IconData selectorIcon,
    required List<_QuickActionData> actions,
  }) {
    return Column(
      children: [
        Text(
          eyebrow,
          style: TextStyle(
            color: Colors.white.withOpacity(0.78),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.15,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                amount,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                ),
              ),
            ),
            const SizedBox(width: 2),
            Text(
              decimal,
              style: TextStyle(
                color: Colors.white.withOpacity(0.62),
                fontSize: 24,
                height: 1.05,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selectorIcon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  selector,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 21,
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions
              .map(
                (item) => SizedBox(
              width: 76,
              child: Column(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.13),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
              .toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              size: 28,
              color: Color(0xFF5B6470),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                searchHint,
                style: const TextStyle(
                  color: Color(0xFFA4ABB3),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTENT
  // ---------------------------------------------------------------------------

  Widget _buildSelectedContent() {
    switch (selectedTab) {
      case 1:
        return _buildAccountsSection();

      case 2:
        return _buildCardsSection();

      case 3:
        return _buildInvestmentsSection();

      case 4:
        return _buildLoansSection();

      default:
        return _buildOverviewSection();
    }
  }

  Widget _buildOverviewSection() {
    return Column(
      children: [
        _buildAccountsCarousel(),

        const SizedBox(height: 18),

        _buildNoticeBanner(
          icon: Icons.auto_graph_rounded,
          text:
          'Harcamalarını analiz et, aylık bütçeni daha kolay yönet.',
        ),

        const SizedBox(height: 20),

        _buildRecentTransactionsCard(),

        const SizedBox(height: 20),

        _buildInvestmentCard(),

        const SizedBox(height: 20),

        _buildMiniServicesCard(),

        const SizedBox(height: 20),

        _buildSecurityCenterCard(),

        const SizedBox(height: 26),

        _buildLoginHistory(),

        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAccountsSection() {
    if (_accountsLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_accountsError != null) {
      return _sectionCard(
        title: 'Vadesiz Hesaplar',
        child: Column(
          children: [
            const Text(
              'Hesap bilgileri alınamadı.',
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _accountsLoading = true;
                  _accountsError = null;
                });

                _loadAccounts();
              },
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_accounts.isEmpty) {
      return _sectionCard(
        title: 'Vadesiz Hesaplar',
        trailing: '0 hesap',
        child: const Text(
          'Henüz hesabın bulunmuyor.',
        ),
      );
    }

    return Column(
      children: [
        _sectionCard(
          title: 'Vadesiz Hesaplar',
          trailing: '${_accounts.length} hesap',
          child: Column(
            children: [
              for (int i = 0; i < _accounts.length; i++) ...[
                _accountRow(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Kullanılabilir bakiye',
                  amount: _formatMoney(
                    _accounts[i].balance,
                  ),
                  subtitle:
                  'Vadesiz TL • ${_accounts[i].accountNumber}',
                ),
                if (i != _accounts.length - 1)
                  const Divider(height: 28),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildNoticeBanner(
          icon: Icons.savings_outlined,
          text:
          'Birikimlerini otomatik talimatla düzenli hale getir.',
        ),
      ],
    );
  }

  Widget _buildCardsSection() {
    return Column(
      children: [
        _buildPremiumCreditCard(),

        const SizedBox(height: 20),

        _sectionCard(
          title: 'Kredi kartım',
          trailing: '1 kart',
          child: Column(
            children: [
              _detailRow(
                'Kullanılabilir limit',
                '49.255,46 TL',
              ),
              const SizedBox(height: 13),
              _detailRow(
                'Dönem içi harcama',
                '744,54 TL',
              ),
              const SizedBox(height: 13),
              _detailRow(
                'Son ödeme tarihi',
                '06.09.2026',
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _buildNoticeBanner(
          icon: Icons.workspace_premium_outlined,
          text: 'Premium kart ayrıcalıklarını keşfet.',
        ),
      ],
    );
  }

  Widget _buildInvestmentsSection() {
    return Column(
      children: [
        _sectionCard(
          title: 'Yatırım merkezi',
          child: Row(
            children: [
              Expanded(
                child: _smallShortcut(
                  icon: Icons.format_list_bulleted_rounded,
                  label: 'Listelerim',
                ),
              ),
              Container(
                width: 1,
                height: 58,
                color: const Color(0xFFE7E9ED),
              ),
              Expanded(
                child: _smallShortcut(
                  icon: Icons.show_chart_rounded,
                  label: 'Piyasalar',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _sectionCard(
          title: 'Döviz',
          trailing: 'Portföyüm',
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: Color(0xFFE9EEF5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '€',
                    style: TextStyle(
                      color: navy,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Euro',
                      style: TextStyle(
                        color: text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '3,00 EUR',
                      style: TextStyle(
                        color: muted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '165,63 TL',
                    style: TextStyle(
                      color: text,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '-2,91 TL • % -1,73',
                    style: TextStyle(
                      color: Color(0xFFC35555),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoansSection() {
    return Column(
      children: [
        _sectionCard(
          title: 'Aktif Kredim',
          trailing: '1 kredi',
          child: Column(
            children: [
              _detailRow(
                'Kalan borç',
                '24.850,00 TL',
              ),
              const SizedBox(height: 13),
              _detailRow(
                'Aylık taksit',
                '2.485,00 TL',
              ),
              const SizedBox(height: 13),
              _detailRow(
                'Kalan taksit',
                '10',
              ),
              const SizedBox(height: 13),
              _detailRow(
                'Sonraki ödeme',
                '04.09.2026',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildOfferCard(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // CAROUSEL
  // ---------------------------------------------------------------------------

  Widget _buildAccountsCarousel() {
    if (_accountsLoading) {
      return const SizedBox(
        height: 184,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_accounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 184,
      child: PageView(
        controller: PageController(
          viewportFraction: 0.92,
        ),
        padEnds: false,
        children: _accounts.map((account) {
          return _buildFinanceCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Vadesiz Hesap',
            number: account.accountNumber,
            balanceTitle: 'Kullanılabilir bakiye',
            amount: _formatWhole(account.balance),
            decimal: _formatDecimal(account.balance),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFinanceCard({
    required IconData icon,
    required String title,
    required String number,
    required String balanceTitle,
    required String amount,
    required String decimal,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(18),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _roundIcon(icon),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      number,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.more_horiz_rounded,
                color: muted,
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Divider(height: 1),

          const SizedBox(height: 13),

          Text(
            balanceTitle,
            style: const TextStyle(
              color: muted,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 5),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: text,
                    fontSize: 25,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                  ),
                ),
              ),
              Text(
                decimal,
                style: const TextStyle(
                  color: muted,
                  fontSize: 17,
                  height: 1.05,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RECENT TRANSACTIONS
  // ---------------------------------------------------------------------------

  Widget _buildRecentTransactionsCard() {
    return _sectionCard(
      title: 'Son işlemler',
      trailingWidget: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: navy,
          shape: BoxShape.circle,
        ),
        child: const Text(
          '1',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _roundIcon(
            Icons.shopping_bag_outlined,
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Market',
                  style: TextStyle(
                    color: text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Migros',
                  style: TextStyle(
                    color: muted,
                    fontSize: 13.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Bugün • 11:42',
                  style: TextStyle(
                    color: Color(0xFFA6AEB7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-424,95 TL',
                style: TextStyle(
                  color: text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Tamamlandı',
                style: TextStyle(
                  color: Color(0xFF3A8D6D),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INVESTMENT CARD
  // ---------------------------------------------------------------------------

  Widget _buildInvestmentCard() {
    return _sectionCard(
      title: 'Yatırımlarım',
      trailingWidget: const Icon(
        Icons.visibility_outlined,
        color: muted,
        size: 22,
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '165',
                  style: TextStyle(
                    color: text,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  ',63 TL',
                  style: TextStyle(
                    color: muted,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Divider(height: 1),

          const SizedBox(height: 16),

          Row(
            children: [
              _roundIcon(
                Icons.currency_exchange_rounded,
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Text(
                  'Döviz',
                  style: TextStyle(
                    color: text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '165,63 TL',
                    style: TextStyle(
                      color: text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '-2,91 TL',
                    style: TextStyle(
                      color: Color(0xFFC35555),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MINI SERVICES
  // ---------------------------------------------------------------------------

  Widget _buildMiniServicesCard() {
    return _sectionCard(
      title: 'Senin için',
      child: Row(
        children: [
          Expanded(
            child: _miniService(
              icon: Icons.directions_car_filled_outlined,
              title: 'Aracım',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _miniService(
              icon: Icons.home_work_outlined,
              title: 'Evim',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _miniService(
              icon: Icons.flight_takeoff_rounded,
              title: 'Seyahatim',
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniService({
    required IconData icon,
    required String title,
  }) {
    return Column(
      children: [
        Container(
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F5F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(
              icon,
              color: navy,
              size: 29,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: text,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SECURITY
  // ---------------------------------------------------------------------------

  Widget _buildSecurityCenterCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E6EA),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Güvenliğin için yanındayız',
            style: TextStyle(
              color: text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 15),

          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.shield_outlined,
              color: navy,
            ),
            label: const Text(
              'Güvenlik Merkezi',
              style: TextStyle(
                color: navy,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: navy,
                width: 1.3,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Divider(height: 1),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _securityAction(
                  Icons.support_agent_rounded,
                  'Beni arayan\nbanka mı?',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _securityAction(
                  Icons.warning_amber_rounded,
                  'Acil durum\nbildireceğim',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _securityAction(
      IconData icon,
      String label,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: teal,
            size: 22,
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: text,
                fontSize: 12.5,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOGIN HISTORY
  // ---------------------------------------------------------------------------

  Widget _buildLoginHistory() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        4,
        4,
        4,
        0,
      ),
      child: Column(
        children: [
          _InfoRow(
            title: 'SON BAŞARILI GİRİŞ',
            value: 'Bugün 12:56',
          ),

          SizedBox(height: 12),

          _InfoRow(
            title: 'GİRİŞ YAPILAN KANAL',
            value: 'Mobil Uygulama',
          ),

          SizedBox(height: 12),

          _InfoRow(
            title: 'SON BAŞARISIZ GİRİŞ',
            value: '24.08.2026 18:16',
          ),

          SizedBox(height: 12),

          _InfoRow(
            title: 'BAŞARISIZ GİRİŞ KANALI',
            value: 'Web',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PREMIUM CREDIT CARD
  // ---------------------------------------------------------------------------

  Widget _buildPremiumCreditCard() {
    return AspectRatio(
      aspectRatio: 1.58,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF071B2D),
              Color(0xFF123B52),
              Color(0xFF0D7377),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: navy.withOpacity(0.25),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              Positioned(
                right: -60,
                top: -75,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 34,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: -70,
                bottom: -120,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.035),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const _CardLogo(),

                        const SizedBox(width: 10),

                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IBT BANK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 9,
                                letterSpacing: 2.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        const Icon(
                          Icons.contactless_rounded,
                          color: Colors.white70,
                          size: 28,
                        ),
                      ],
                    ),

                    const Spacer(),

                    const _CardChip(),

                    const SizedBox(height: 15),

                    const Text(
                      '5412  ••••  ••••  8926',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        letterSpacing: 1.9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'KART SAHİBİ',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 9.5,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'İBRAHİM BATUHAN TOPTANCI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  letterSpacing: 0.6,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'VALID THRU',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 8.5,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              '08/31',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Widget _sectionCard({
    required String title,
    String? trailing,
    Widget? trailingWidget,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _whiteCardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const Spacer(),

              if (trailing != null)
                Text(
                  trailing,
                  style: TextStyle(
                    color:
                    trailing == 'Portföyüm' ? teal : muted,
                    fontSize: 13.5,
                    fontWeight:
                    trailing == 'Portföyüm'
                        ? FontWeight.w700
                        : FontWeight.w600,
                    decoration:
                    trailing == 'Portföyüm'
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),

              if (trailingWidget != null)
                trailingWidget,
            ],
          ),

          const SizedBox(height: 16),

          const Divider(height: 1),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }

  BoxDecoration _whiteCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: const Color(0xFFE8EBEF),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.045),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _roundIcon(
      IconData icon,
      ) {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        color: Color(0xFFEAF3F5),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: teal,
        size: 23,
      ),
    );
  }

  Widget _accountRow({
    required IconData icon,
    required String title,
    required String amount,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _roundIcon(icon),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                amount,
                style: const TextStyle(
                  color: text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: muted,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),

        const Icon(
          Icons.more_horiz_rounded,
          color: muted,
        ),
      ],
    );
  }

  Widget _detailRow(
      String title,
      String value,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: muted,
              fontSize: 13.5,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: text,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _smallShortcut({
    required IconData icon,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _roundIcon(icon),

          const SizedBox(width: 9),

          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeBanner({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        14,
        13,
        12,
        13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEFEA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.all(
                Radius.circular(13),
              ),
            ),
            child: Icon(
              icon,
              color: teal,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF22655D),
                fontSize: 13.5,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const Icon(
            Icons.close_rounded,
            color: Color(0xFF3F7E75),
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF102A43),
            Color(0xFF174B5C),
          ],
        ),
      ),
      child: const Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 28,
          ),

          SizedBox(height: 16),

          Text(
            'Sana özel kredi fırsatı',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 7),

          Text(
            'İhtiyacına uygun ödeme planını birkaç adımda oluştur.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM NAVIGATION
  // ---------------------------------------------------------------------------

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: navy,
      unselectedItemColor: const Color(0xFF6D7480),
      selectedFontSize: 11.5,
      unselectedFontSize: 11.5,
      elevation: 10,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home_outlined,
          ),
          activeIcon: Icon(
            Icons.home_rounded,
          ),
          label: 'Ana Sayfa',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.swap_horiz_rounded,
          ),
          label: 'Transfer ve Ödeme',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.add_circle_outline_rounded,
          ),
          label: 'İşlemler',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.favorite_border_rounded,
          ),
          label: 'Senin İçin',
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// MODELS / SMALL WIDGETS
// -----------------------------------------------------------------------------

class _QuickActionData {
  final IconData icon;
  final String label;

  const _QuickActionData(
      this.icon,
      this.label,
      );
}

class _CardLogo extends StatelessWidget {
  const _CardLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.55),
          width: 1.2,
        ),
      ),
      child: const Text(
        'IBT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _CardChip extends StatelessWidget {
  const _CardChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 34,
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(8),
        gradient:
        const LinearGradient(
          colors: [
            Color(0xFFD9C07B),
            Color(0xFFF3E1A9),
            Color(0xFFC8A85A),
          ],
        ),
      ),
      child: const Icon(
        Icons.memory_rounded,
        color: Color(0xFF7C6731),
        size: 22,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8A929C),
              fontSize: 11.5,
              letterSpacing: 0.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Color(0xFF5E6670),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}