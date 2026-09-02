import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/account_model.dart';
import '../../services/api_service.dart';
import '../home/account_action_sheet.dart';

class TransferPaymentPage extends StatefulWidget {
  const TransferPaymentPage({super.key});

  @override
  State<TransferPaymentPage> createState() => _TransferPaymentPageState();
}

class _TransferPaymentPageState extends State<TransferPaymentPage> {
  static const Color navy = Color(0xFF102A43);
  static const Color teal = Color(0xFF0E7C86);
  static const Color background = Color(0xFFF4F6F8);
  static const Color text = Color(0xFF17212B);
  static const Color muted = Color(0xFF7C8793);
  static const Color border = Color(0xFFE7EAEE);

  final TextEditingController _searchController = TextEditingController();

  List<AccountModel> _accounts = [];

  bool _loading = true;
  String? _error;

  bool _transfersExpanded = true;
  bool _moneyExpanded = true;
  bool _paymentsExpanded = false;

  String get _query => _searchController.text.trim().toLowerCase();

  bool get _isSearching => _query.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await ApiService.getMyAccounts();

      if (!mounted) return;

      setState(() {
        _accounts = accounts;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _accounts = [];
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _openAction(AccountActionType action) async {
    if (_accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşlem yapılabilecek hesap bulunamadı.')),
      );

      return;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AccountActionSheet(action: action, accounts: _accounts),
    );

    if (result != true) {
      return;
    }

    await _loadAccounts();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_successMessage(action)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _successMessage(AccountActionType action) {
    switch (action) {
      case AccountActionType.deposit:
        return 'Para yatırma işlemi tamamlandı.';

      case AccountActionType.withdraw:
        return 'Para çekme işlemi tamamlandı.';

      case AccountActionType.transfer:
        return 'Transfer başarıyla tamamlandı.';
    }
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title yakında IBT Bank’ta.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _matches(List<String> words) {
    if (!_isSearching) {
      return true;
    }

    return words.any((word) => word.toLowerCase().contains(_query));
  }

  @override
  Widget build(BuildContext context) {
    final showBetweenAccounts = _matches([
      'hesaplarım arasında',
      'hesaplar arası',
      'kendi hesabım',
      'transfer',
    ]);

    final showSendMoney = _matches([
      'para gönder',
      'transfer',
      'havale',
      'hesap numarası',
      'ibt',
    ]);

    final showInternational = _matches([
      'uluslararası transfer',
      'swift',
      'yurt dışı',
    ]);

    final showRequestMoney = _matches(['ödeme iste', 'para iste']);

    final showDeposit = _matches([
      'para yatır',
      'yatırma',
      'bakiye ekle',
      'nakit',
    ]);

    final showWithdraw = _matches(['para çek', 'çekme', 'nakit']);

    final showBill = _matches([
      'fatura',
      'elektrik',
      'su',
      'internet',
      'ödeme',
    ]);

    final showTax = _matches(['vergi', 'harç', 'resmi ödeme']);

    final hasTransfers =
        showBetweenAccounts ||
        showSendMoney ||
        showInternational ||
        showRequestMoney;

    final hasMoney = showDeposit || showWithdraw;

    final hasPayments = showBill || showTax;

    final hasAnyResult = hasTransfers || hasMoney || hasPayments;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: navy,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  color: teal,
                  onRefresh: _loadAccounts,
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                    children: [
                      if (_loading)
                        _buildLoading()
                      else if (_error != null)
                        _buildError()
                      else ...[
                        _buildAccountSummary(),

                        const SizedBox(height: 18),

                        if (!hasAnyResult) _buildNoSearchResult(),

                        if (hasTransfers) ...[
                          _buildSection(
                            title: 'Transferler',
                            icon: Icons.compare_arrows_rounded,
                            expanded: _isSearching || _transfersExpanded,
                            onToggle: () {
                              if (_isSearching) {
                                return;
                              }

                              setState(() {
                                _transfersExpanded = !_transfersExpanded;
                              });
                            },
                            children: [
                              if (showSendMoney)
                                _ActionItem(
                                  icon: Icons.person_outline_rounded,
                                  title: 'Para Gönder',
                                  subtitle:
                                      'IBT hesap numarasına para transferi',
                                  onTap: () {
                                    _openAction(AccountActionType.transfer);
                                  },
                                ),
                              if (showBetweenAccounts)
                                _ActionItem(
                                  icon: Icons.swap_horiz_rounded,
                                  title: 'Hesaplarım Arasında',
                                  subtitle: 'Kendi hesapların arasında aktarım',
                                  enabled: false,
                                  onTap: () {
                                    _showComingSoon(
                                      'Hesaplarım arasında transfer',
                                    );
                                  },
                                ),
                              if (showInternational)
                                _ActionItem(
                                  icon: Icons.public_rounded,
                                  title: 'Uluslararası Transfer',
                                  subtitle: 'SWIFT ile yurt dışına para gönder',
                                  enabled: false,
                                  onTap: () {
                                    _showComingSoon('Uluslararası transfer');
                                  },
                                ),
                              if (showRequestMoney)
                                _ActionItem(
                                  icon: Icons.request_quote_outlined,
                                  title: 'Ödeme İste',
                                  subtitle:
                                      'Başka bir IBT müşterisinden ödeme iste',
                                  enabled: false,
                                  onTap: () {
                                    _showComingSoon('Ödeme iste');
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],

                        if (hasMoney) ...[
                          _buildSection(
                            title: 'Para İşlemleri',
                            icon: Icons.account_balance_wallet_outlined,
                            expanded: _isSearching || _moneyExpanded,
                            onToggle: () {
                              if (_isSearching) {
                                return;
                              }

                              setState(() {
                                _moneyExpanded = !_moneyExpanded;
                              });
                            },
                            children: [
                              if (showDeposit)
                                _ActionItem(
                                  icon: Icons.add_circle_outline_rounded,
                                  title: 'Para Yatır',
                                  subtitle: 'Hesabına bakiye ekle',
                                  onTap: () {
                                    _openAction(AccountActionType.deposit);
                                  },
                                ),
                              if (showWithdraw)
                                _ActionItem(
                                  icon: Icons.remove_circle_outline_rounded,
                                  title: 'Para Çek',
                                  subtitle: 'Hesabından para çek',
                                  onTap: () {
                                    _openAction(AccountActionType.withdraw);
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],

                        if (hasPayments)
                          _buildSection(
                            title: 'Ödemeler',
                            icon: Icons.receipt_long_outlined,
                            expanded: _isSearching || _paymentsExpanded,
                            onToggle: () {
                              if (_isSearching) {
                                return;
                              }

                              setState(() {
                                _paymentsExpanded = !_paymentsExpanded;
                              });
                            },
                            children: [
                              if (showBill)
                                _ActionItem(
                                  icon: Icons.lightbulb_outline_rounded,
                                  title: 'Fatura Ödeme',
                                  subtitle: 'Elektrik, su, internet ve diğer faturalar',
                                  enabled: false,
                                  onTap: () {
                                    _showComingSoon('Fatura ödeme');
                                  },
                                ),
                              if (showTax)
                                _ActionItem(
                                  icon: Icons.account_balance_outlined,
                                  title: 'Vergi ve Harçlar',
                                  subtitle: 'Vergi ve resmi ödeme işlemleri',
                                  enabled: false,
                                  onTap: () {
                                    _showComingSoon('Vergi ve harç ödemeleri');
                                  },
                                ),
                            ],
                          ),
                      ],
                    ],
                  ),
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
      decoration: const BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
      child: Column(
        children: [
          const SizedBox(height: 4),

          const Text(
            'Transfer ve Ödemeler',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.35,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Tüm para işlemlerin tek yerde',
            style: TextStyle(color: Colors.white70, fontSize: 12.5),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'İşlem ara',
              hintStyle: const TextStyle(color: muted),
              prefixIcon: const Icon(Icons.search_rounded, color: muted),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        FocusScope.of(context).unfocus();

                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded, color: muted),
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: teal, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSummary() {
    final totalBalance = _accounts.fold<double>(
      0,
      (total, account) => total + account.balance,
    );

    final AccountModel? primaryAccount = _accounts.isEmpty
        ? null
        : _accounts.first;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F3F4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: teal,
                  size: 24,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kullanılabilir Bakiye',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatMoney(totalBalance),
                      style: const TextStyle(
                        color: text,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_accounts.length} hesap',
                  style: const TextStyle(
                    color: teal,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          if (primaryAccount != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF0F1F3)),
            const SizedBox(height: 13),

            Row(
              children: [
                const Icon(
                  Icons.account_balance_outlined,
                  color: muted,
                  size: 18,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    primaryAccount.accountNumber,
                    style: const TextStyle(
                      color: text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: primaryAccount.accountNumber),
                    );

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hesap numarası kopyalandı.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.copy_rounded, color: teal, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required bool expanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F3F4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: teal, size: 22),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: text,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: muted,
                      size: 27,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            child: expanded
                ? Column(
                    children: [
                      const Divider(height: 1, color: Color(0xFFEEF0F2)),
                      ...children,
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.only(top: 100),
      child: Center(child: CircularProgressIndicator(color: teal)),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F3F4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: teal,
              size: 28,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            _error ?? 'Hesap bilgileri alınamadı.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: text, height: 1.4),
          ),

          const SizedBox(height: 16),

          FilledButton(
            onPressed: _loadAccounts,
            style: FilledButton.styleFrom(backgroundColor: navy),
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResult() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, color: muted, size: 42),
          const SizedBox(height: 12),
          const Text(
            'İşlem bulunamadı',
            style: TextStyle(
              color: text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '"${_searchController.text}" için eşleşen bir işlem yok.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  String _formatMoney(double value) {
    final fixed = value.toStringAsFixed(2);

    final split = fixed.split('.');
    final whole = split[0];
    final decimal = split[1];

    final buffer = StringBuffer();

    for (int i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(whole[i]);
    }

    return '${buffer.toString()},$decimal TL';
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF0E7C86);
    const text = Color(0xFF17212B);
    const muted = Color(0xFF7C8793);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: enabled
                    ? const Color(0xFFF7FAFA)
                    : const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: enabled
                      ? const Color(0xFFDCE8E9)
                      : const Color(0xFFE5E7E9),
                ),
              ),
              child: Icon(icon, color: enabled ? teal : muted, size: 21),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: enabled ? text : muted,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            if (!enabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Text(
                  'Yakında',
                  style: TextStyle(
                    color: muted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: muted, size: 22),
          ],
        ),
      ),
    );
  }
}
