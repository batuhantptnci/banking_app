import 'package:flutter/material.dart';

import 'package:banking_app/models/account_model.dart';
import 'package:banking_app/services/api_service.dart';

enum AccountActionType { deposit, withdraw, transfer }

class AccountActionSheet extends StatefulWidget {
  final AccountActionType action;
  final List<AccountModel> accounts;

  const AccountActionSheet({
    super.key,
    required this.action,
    required this.accounts,
  });

  @override
  State<AccountActionSheet> createState() => _AccountActionSheetState();
}

class _AccountActionSheetState extends State<AccountActionSheet> {
  static const Color navy = Color(0xFF102A43);
  static const Color teal = Color(0xFF0E7C86);

  final TextEditingController _amountController = TextEditingController();

  final TextEditingController _receiverController = TextEditingController();

  late AccountModel _selectedAccount;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.accounts.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _receiverController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.action) {
      case AccountActionType.deposit:
        return 'Para Yatır';

      case AccountActionType.withdraw:
        return 'Para Çek';

      case AccountActionType.transfer:
        return 'Para Transferi';
    }
  }

  String get _buttonText {
    switch (widget.action) {
      case AccountActionType.deposit:
        return 'Parayı Yatır';

      case AccountActionType.withdraw:
        return 'Parayı Çek';

      case AccountActionType.transfer:
        return 'Transferi Tamamla';
    }
  }

  double? _parseAmount() {
    final normalized = _amountController.text
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '.');

    return double.tryParse(normalized);
  }

  Future<void> _submit() async {
    if (_loading) return;

    final amount = _parseAmount();

    if (amount == null || amount <= 0) {
      setState(() {
        _error = 'Geçerli bir tutar giriniz.';
      });

      return;
    }

    if (widget.action == AccountActionType.transfer &&
        _receiverController.text.trim().isEmpty) {
      setState(() {
        _error = 'Alıcı hesap numarasını giriniz.';
      });

      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      switch (widget.action) {
        case AccountActionType.deposit:
          await ApiService.deposit(
            accountId: _selectedAccount.id,
            amount: amount,
          );
          break;

        case AccountActionType.withdraw:
          await ApiService.withdraw(
            accountId: _selectedAccount.id,
            amount: amount,
          );
          break;

        case AccountActionType.transfer:
          await ApiService.transfer(
            fromAccountId: _selectedAccount.id,
            toAccountNumber: _receiverController.text,
            amount: amount,
          );
          break;
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6DADE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Text(
                _title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 22),

              DropdownButtonFormField<AccountModel>(
                initialValue: _selectedAccount,
                decoration: InputDecoration(
                  labelText: 'Hesap',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: widget.accounts
                    .map(
                      (account) => DropdownMenuItem(
                        value: account,
                        child: Text(account.accountNumber),
                      ),
                    )
                    .toList(),
                onChanged: _loading
                    ? null
                    : (account) {
                        if (account == null) {
                          return;
                        }

                        setState(() {
                          _selectedAccount = account;
                        });
                      },
              ),

              if (widget.action == AccountActionType.transfer) ...[
                const SizedBox(height: 16),

                TextField(
                  controller: _receiverController,
                  enabled: !_loading,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Alıcı hesap numarası',
                    hintText: 'ACC-XXXXXXXX',
                    prefixIcon: const Icon(Icons.account_balance_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              TextField(
                controller: _amountController,
                enabled: !_loading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Tutar',
                  hintText: '0,00',
                  suffixText: 'TL',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              if (widget.action != AccountActionType.deposit) ...[
                const SizedBox(height: 10),

                Text(
                  'Kullanılabilir bakiye: '
                  '${_selectedAccount.balance.toStringAsFixed(2)} TL',
                  style: const TextStyle(
                    color: Color(0xFF7C8793),
                    fontSize: 13,
                  ),
                ),
              ],

              if (_error != null) ...[
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Color(0xFFB42318),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _buttonText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
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
