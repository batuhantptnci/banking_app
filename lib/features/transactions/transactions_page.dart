import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'transaction_detail_page.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';
import '../../services/api_service.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  static const Color navy = Color(0xFF102A43);
  static const Color teal = Color(0xFF0E7C86);
  static const Color background = Color(0xFFF4F6F8);
  static const Color text = Color(0xFF17212B);
  static const Color muted = Color(0xFF7C8793);

  List<TransactionModel> _transactions = [];

  bool _loading = true;
  String? _error;

  String _filter = 'ALL';

  @override
  void initState() {
    super.initState();

    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final accounts = await ApiService.getMyAccounts();

      final results = await Future.wait(
        accounts.map(
          (AccountModel account) =>
              ApiService.getAccountTransactions(account.id),
        ),
      );

      final unique = <int, TransactionModel>{};

      for (final list in results) {
        for (final transaction in list) {
          unique[transaction.id] = transaction;
        }
      }

      final transactions = unique.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!mounted) return;

      setState(() {
        _transactions = transactions;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _transactions = [];
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<TransactionModel> get _filteredTransactions {
    switch (_filter) {
      case 'INCOMING':
        return _transactions
            .where((transaction) => transaction.isIncoming)
            .toList();

      case 'OUTGOING':
        return _transactions
            .where((transaction) => !transaction.isIncoming)
            .toList();

      default:
        return _transactions;
    }
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
                  onRefresh: _loadTransactions,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                    children: [
                      _buildFilters(),

                      const SizedBox(height: 18),

                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: Center(
                            child: CircularProgressIndicator(color: teal),
                          ),
                        )
                      else if (_error != null)
                        _buildError()
                      else if (_filteredTransactions.isEmpty)
                        _buildEmpty()
                      else
                        _buildTransactionCard(),
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: const Column(
        children: [
          Text(
            'İşlemler',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Tüm hesap hareketlerin',
            style: TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _filterButton(value: 'ALL', label: 'Tümü'),
        const SizedBox(width: 8),
        _filterButton(value: 'INCOMING', label: 'Gelen'),
        const SizedBox(width: 8),
        _filterButton(value: 'OUTGOING', label: 'Giden'),
      ],
    );
  }

  Widget _filterButton({required String value, required String label}) {
    final selected = _filter == value;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          setState(() {
            _filter = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? navy : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? navy : const Color(0xFFE2E6E9),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard() {
    final transactions = _filteredTransactions;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EAEE)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, indent: 78, color: Color(0xFFEEF0F2)),
        itemBuilder: (context, index) {
          return _transactionRow(transactions[index]);
        },
      ),
    );
  }

  Widget _transactionRow(TransactionModel transaction) {
    final incoming = transaction.isIncoming;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailPage(transaction: transaction),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F3F4),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconFor(transaction), color: teal),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleFor(transaction),
                    style: const TextStyle(
                      color: text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _formatDate(transaction.createdAt),
                    style: const TextStyle(color: muted, fontSize: 11.5),
                  ),
                  if (transaction.balanceAfter != null) ...[
                    const SizedBox(height: 5),

                    Text(
                      'İşlem sonrası bakiye: '
                      '${_formatMoney(transaction.balanceAfter!)}',
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${incoming ? '+' : '-'}${_formatMoney(transaction.amount)}',
                  style: TextStyle(
                    color: incoming
                        ? const Color(0xFF2E8B6D)
                        : const Color(0xFFC74B50),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                const Icon(Icons.chevron_right_rounded, color: muted, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined, color: muted, size: 42),
          SizedBox(height: 12),
          Text(
            'Henüz gösterilecek işlem yok.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: teal, size: 40),
          const SizedBox(height: 12),
          Text(_error ?? 'İşlemler alınamadı.', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loadTransactions,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  String _titleFor(TransactionModel transaction) {
    switch (transaction.type) {
      case 'DEPOSIT':
        return 'Para Yatırma';

      case 'WITHDRAW':
        return 'Para Çekme';

      case 'TRANSFER':
        return transaction.isIncoming ? 'Gelen Transfer' : 'Giden Transfer';

      default:
        return 'Banka İşlemi';
    }
  }

  IconData _iconFor(TransactionModel transaction) {
    switch (transaction.type) {
      case 'DEPOSIT':
        return Icons.add_circle_outline_rounded;

      case 'WITHDRAW':
        return Icons.remove_circle_outline_rounded;

      case 'TRANSFER':
        return Icons.swap_horiz_rounded;

      default:
        return Icons.receipt_long_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    final hour = date.hour.toString().padLeft(2, '0');

    final minute = date.minute.toString().padLeft(2, '0');

    return '$day.$month.${date.year} • $hour:$minute';
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
