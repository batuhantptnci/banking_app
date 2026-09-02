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

  final TextEditingController _searchController = TextEditingController();

  List<AccountModel> _accounts = [];

  bool _loading = true;
  String? _error;

  bool _transfersExpanded = true;
  bool _moneyExpanded = true;
  bool _paymentsExpanded = false;

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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AccountActionSheet(action: action, accounts: _accounts),
    );

    if (result != true) {
      return;
    }

    await _loadAccounts();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(_successMessage(action))));
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$title yakında IBT Bank’ta.')));
  }

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
                child: RefreshIndicator(
                  onRefresh: _loadAccounts,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                    children: [
                      if (_loading) _buildLoading(),

                      if (!_loading && _error != null) _buildError(),

                      if (!_loading && _error == null) ...[
                        _buildAccountSummary(),

                        const SizedBox(height: 18),

                        _buildSection(
                          title: 'Transferler',
                          icon: Icons.compare_arrows_rounded,
                          expanded: _transfersExpanded,
                          onToggle: () {
                            setState(() {
                              _transfersExpanded = !_transfersExpanded;
                            });
                          },
                          children: [
                            _ActionItem(
                              icon: Icons.swap_horiz_rounded,
                              title: 'Hesaplarım arasında',
                              subtitle: 'Kendi hesapların arasında aktarım',
                              enabled: false,
                              onTap: () {
                                _showComingSoon('Hesaplarım arasında transfer');
                              },
                            ),
                            _ActionItem(
                              icon: Icons.person_outline_rounded,
                              title: 'Para gönder',
                              subtitle: 'IBT hesap numarasına transfer',
                              onTap: () {
                                _openAction(AccountActionType.transfer);
                              },
                            ),
                            _ActionItem(
                              icon: Icons.public_rounded,
                              title: 'Uluslararası transfer',
                              subtitle: 'SWIFT işlemleri',
                              enabled: false,
                              onTap: () {
                                _showComingSoon('Uluslararası transfer');
                              },
                            ),
                            _ActionItem(
                              icon: Icons.request_quote_outlined,
                              title: 'Ödeme iste',
                              subtitle: 'Başka bir müşteriden ödeme iste',
                              enabled: false,
                              onTap: () {
                                _showComingSoon('Ödeme iste');
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        _buildSection(
                          title: 'Para işlemleri',
                          icon: Icons.account_balance_wallet_outlined,
                          expanded: _moneyExpanded,
                          onToggle: () {
                            setState(() {
                              _moneyExpanded = !_moneyExpanded;
                            });
                          },
                          children: [
                            _ActionItem(
                              icon: Icons.add_circle_outline_rounded,
                              title: 'Para yatır',
                              subtitle: 'Hesabına bakiye ekle',
                              onTap: () {
                                _openAction(AccountActionType.deposit);
                              },
                            ),
                            _ActionItem(
                              icon: Icons.remove_circle_outline_rounded,
                              title: 'Para çek',
                              subtitle: 'Hesabından para çek',
                              onTap: () {
                                _openAction(AccountActionType.withdraw);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        _buildSection(
                          title: 'Ödemeler',
                          icon: Icons.receipt_long_outlined,
                          expanded: _paymentsExpanded,
                          onToggle: () {
                            setState(() {
                              _paymentsExpanded = !_paymentsExpanded;
                            });
                          },
                          children: [
                            _ActionItem(
                              icon: Icons.lightbulb_outline_rounded,
                              title: 'Fatura ödeme',
                              subtitle:
                                  'Elektrik, su, internet ve diğer faturalar',
                              enabled: false,
                              onTap: () {
                                _showComingSoon('Fatura ödeme');
                              },
                            ),
                            _ActionItem(
                              icon: Icons.account_balance_outlined,
                              title: 'Vergi ve harçlar',
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
      color: navy,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          const Text(
            'Transfer ve Ödemeler',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Transfer veya ödeme ara',
              hintStyle: const TextStyle(color: muted),
              prefixIcon: const Icon(Icons.search_rounded, color: text),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: teal, width: 1.4),
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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EAEE)),
      ),
      child: Row(
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
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kullanılabilir toplam bakiye',
                  style: TextStyle(color: muted, fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMoney(totalBalance),
                  style: const TextStyle(
                    color: text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${_accounts.length} hesap',
            style: const TextStyle(
              color: teal,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EAEE)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F3F4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: teal, size: 25),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: text,
                        fontSize: 19,
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
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                const Divider(height: 1, color: Color(0xFFEEF0F2)),
                ...children,
              ],
            ),
            secondChild: const SizedBox(width: double.infinity),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: teal, size: 38),

          const SizedBox(height: 12),

          Text(
            _error ?? 'Hesap bilgileri alınamadı.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 14),

          FilledButton(
            onPressed: _loadAccounts,
            child: const Text('Tekrar Dene'),
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
        padding: const EdgeInsets.fromLTRB(18, 15, 14, 15),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E5E8)),
              ),
              child: Icon(icon, color: enabled ? teal : muted, size: 23),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: enabled ? text : muted,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            if (!enabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Yakında',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: muted),
          ],
        ),
      ),
    );
  }
}
