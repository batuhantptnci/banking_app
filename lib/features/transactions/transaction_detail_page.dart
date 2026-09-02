import 'package:flutter/material.dart';

import '../../models/transaction_model.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionModel transaction;
  final bool showSuccess;

  const TransactionDetailPage({
    super.key,
    required this.transaction,
    this.showSuccess = false,
  });

  static const Color navy = Color(0xFF102A43);

  static const Color teal = Color(0xFF0E7C86);

  static const Color background = Color(0xFFF4F6F8);

  static const Color text = Color(0xFF17212B);

  static const Color muted = Color(0xFF7C8793);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          showSuccess ? 'İşlem Sonucu' : 'İşlem Detayı',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 30),
          children: [
            if (showSuccess) _buildSuccessHeader(),

            if (showSuccess) const SizedBox(height: 18),

            _buildAmountCard(),

            const SizedBox(height: 16),

            _buildDetailCard(),

            const SizedBox(height: 22),

            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Tamam',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            color: Color(0xFFE3F5ED),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF218A63),
            size: 42,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'İşlemin Tamamlandı',
          style: TextStyle(
            color: navy,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'İşlem başarıyla gerçekleştirildi.',
          style: TextStyle(color: muted, fontSize: 12.5),
        ),
      ],
    );
  }

  Widget _buildAmountCard() {
    final incoming = transaction.isIncoming;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6E9EC)),
      ),
      child: Column(
        children: [
          Text(
            _title,
            style: const TextStyle(
              color: muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${incoming ? '+' : '-'}${_formatMoney(transaction.amount)}',
            style: TextStyle(
              color: incoming
                  ? const Color(0xFF218A63)
                  : const Color(0xFFC74B50),
              fontSize: 29,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Tamamlandı',
              style: TextStyle(
                color: teal,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6E9EC)),
      ),
      child: Column(
        children: [
          _row('İşlem No', '#${transaction.id}'),

          _divider(),

          _row('Tarih', _formatDate(transaction.createdAt)),

          _divider(),

          _row('Saat', _formatTime(transaction.createdAt)),

          _divider(),

          if (transaction.isTransfer) ...[
            _row('Gönderen', transaction.accountHolderName ?? '-'),
            _divider(),
            _row('Gönderen Hesap', transaction.accountNumber ?? '-'),
            _divider(),
            _row('Alıcı', transaction.targetAccountHolderName ?? '-'),
            _divider(),
            _row('Alıcı Hesap', transaction.targetAccountNumber ?? '-'),
            _divider(),
          ] else ...[
            _row('Hesap Sahibi', transaction.accountHolderName ?? '-'),
            _divider(),
            _row('Hesap', transaction.accountNumber ?? '-'),
            _divider(),
          ],

          if (transaction.balanceAfter != null) ...[
            _row(
              'İşlem Sonrası Bakiye',
              _formatMoney(transaction.balanceAfter!),
              highlight: true,
            ),

            _divider(),
          ],

          _row('Açıklama', transaction.description),

          _divider(),

          _row('Kanal', transaction.channel),

          _divider(),

          _row(
            'Durum',
            transaction.status == 'COMPLETED'
                ? 'Tamamlandı'
                : transaction.status,
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: highlight ? teal : text,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, color: Color(0xFFF0F2F3));
  }

  String get _title {
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

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');

    final month = value.month.toString().padLeft(2, '0');

    return '$day.$month.${value.year}';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');

    final minute = value.minute.toString().padLeft(2, '0');

    final second = value.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
  }

  String _formatMoney(double value) {
    final parts = value.toStringAsFixed(2).split('.');

    final whole = parts[0];
    final decimal = parts[1];

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
