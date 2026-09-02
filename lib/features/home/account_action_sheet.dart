import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static const Color background = Color(0xFFF4F6F8);
  static const Color text = Color(0xFF17212B);
  static const Color muted = Color(0xFF7C8793);
  static const Color border = Color(0xFFE3E7EA);

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
        return 'Para Gönder';
    }
  }

  String get _description {
    switch (widget.action) {
      case AccountActionType.deposit:
        return 'Hesabına yatırmak istediğin tutarı gir.';

      case AccountActionType.withdraw:
        return 'Hesabından çekmek istediğin tutarı gir.';

      case AccountActionType.transfer:
        return 'IBT hesap numarası ile para gönder.';
    }
  }

  String get _buttonText {
    switch (widget.action) {
      case AccountActionType.deposit:
        return 'Para Yatır';

      case AccountActionType.withdraw:
        return 'Para Çek';

      case AccountActionType.transfer:
        return 'Devam Et';
    }
  }

  IconData get _actionIcon {
    switch (widget.action) {
      case AccountActionType.deposit:
        return Icons.add_circle_outline_rounded;

      case AccountActionType.withdraw:
        return Icons.remove_circle_outline_rounded;

      case AccountActionType.transfer:
        return Icons.send_rounded;
    }
  }

  double? _parseAmount() {
    final normalized = _amountController.text
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '.');

    return double.tryParse(normalized);
  }

  void _setQuickAmount(double amount) {
    final formatted = _TurkishMoneyInputFormatter.formatValue(amount);

    final commaIndex = formatted.indexOf(',');

    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: commaIndex),
    );

    setState(() {
      _error = null;
    });
  }

  String? _validate(double? amount) {
    if (amount == null || amount <= 0) {
      return 'Geçerli bir tutar giriniz.';
    }

    if (widget.action != AccountActionType.deposit &&
        amount > _selectedAccount.balance) {
      return 'Yetersiz bakiye.';
    }

    if (widget.action == AccountActionType.transfer) {
      final receiver = _receiverController.text.trim().toUpperCase();

      if (receiver.isEmpty) {
        return 'Alıcı hesap numarasını giriniz.';
      }

      final validAccount = RegExp(r'^ACC-[A-Z0-9]{8}$').hasMatch(receiver);

      if (!validAccount) {
        return 'Hesap numarası ACC-XXXXXXXX formatında olmalıdır.';
      }

      if (receiver == _selectedAccount.accountNumber.toUpperCase()) {
        return 'Kendi hesabına transfer yapamazsın.';
      }
    }

    return null;
  }

  Future<void> _handleSubmit() async {
    if (_loading) return;

    final amount = _parseAmount();

    final validationError = _validate(amount);

    if (validationError != null) {
      setState(() {
        _error = validationError;
      });

      return;
    }

    final confirmed = await _showConfirmation(amount!);

    if (confirmed != true || !mounted) {
      return;
    }

    await _submit(amount);
  }

  Future<bool?> _showConfirmation(double amount) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
          contentPadding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
          actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F3F4),
                  shape: BoxShape.circle,
                ),
                child: Icon(_actionIcon, color: teal, size: 21),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'İşlemi Onayla',
                  style: TextStyle(
                    color: navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _confirmationRow('İşlem', _title),

              _confirmationRow('Hesap', _selectedAccount.accountNumber),

              if (widget.action == AccountActionType.transfer)
                _confirmationRow(
                  'Alıcı',
                  _receiverController.text.trim().toUpperCase(),
                ),

              _confirmationRow('Tutar', _formatMoney(amount), highlight: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(backgroundColor: teal),
              child: const Text('Onayla'),
            ),
          ],
        );
      },
    );
  }

  Widget _confirmationRow(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
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
                fontSize: highlight ? 16 : 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(double amount) async {
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
    return Container(
      decoration: const BoxDecoration(
        color: background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            10,
            18,
            18 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCED4D9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F3F4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_actionIcon, color: teal, size: 25),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title,
                            style: const TextStyle(
                              color: navy,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            _description,
                            style: const TextStyle(
                              color: muted,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _buildAccountSelector(),

                if (widget.action == AccountActionType.transfer) ...[
                  const SizedBox(height: 15),
                  _buildReceiverField(),
                ],

                const SizedBox(height: 15),

                _buildAmountField(),

                const SizedBox(height: 12),

                _buildQuickAmounts(),

                if (widget.action != AccountActionType.deposit) ...[
                  const SizedBox(height: 14),
                  _buildBalanceInfo(),
                ],

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  _buildError(),
                ],

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _loading ? null : _handleSubmit,
                    style: FilledButton.styleFrom(
                      backgroundColor: teal,
                      disabledBackgroundColor: const Color(0xFFB8CBCD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _buttonText,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İşlem yapılacak hesap',
            style: TextStyle(
              color: muted,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 3),

          DropdownButtonHideUnderline(
            child: DropdownButton<AccountModel>(
              value: _selectedAccount,
              isExpanded: true,
              menuMaxHeight: 320,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: muted),

              selectedItemBuilder: (context) {
                return widget.accounts.map((account) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      account.accountNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList();
              },

              items: widget.accounts.map((account) {
                return DropdownMenuItem<AccountModel>(
                  value: account,
                  child: Text(
                    account.accountNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),

              onChanged: _loading
                  ? null
                  : (account) {
                      if (account == null) {
                        return;
                      }

                      setState(() {
                        _selectedAccount = account;
                        _error = null;
                      });
                    },
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7F8),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                const Text(
                  'Bakiye',
                  style: TextStyle(color: muted, fontSize: 11.5),
                ),

                const Spacer(),

                Flexible(
                  child: Text(
                    _formatMoney(_selectedAccount.balance),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiverField() {
    return TextField(
      controller: _receiverController,
      enabled: !_loading,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
        LengthLimitingTextInputFormatter(12),
        _UpperCaseTextFormatter(),
      ],
      onChanged: (_) {
        if (_error != null) {
          setState(() {
            _error = null;
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Alıcı hesap numarası',
        hintText: 'ACC-XXXXXXXX',
        prefixIcon: const Icon(Icons.account_balance_outlined, color: teal),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: teal, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextField(
      controller: _amountController,
      enabled: !_loading,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [_TurkishMoneyInputFormatter()],
      onChanged: (_) {
        if (_error != null) {
          setState(() {
            _error = null;
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Tutar',
        hintText: '0,00',
        suffixText: 'TL',
        prefixIcon: const Icon(Icons.payments_outlined, color: teal),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: teal, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildQuickAmounts() {
    return Row(
      children: [
        _quickAmountButton(100),
        const SizedBox(width: 8),
        _quickAmountButton(500),
        const SizedBox(width: 8),
        _quickAmountButton(1000),
      ],
    );
  }

  Widget _quickAmountButton(double amount) {
    return Expanded(
      child: OutlinedButton(
        onPressed: _loading
            ? null
            : () {
                _setQuickAmount(amount);
              },
        style: OutlinedButton.styleFrom(
          foregroundColor: navy,
          padding: const EdgeInsets.symmetric(vertical: 10),
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Text(
          '${amount.toStringAsFixed(0)} TL',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildBalanceInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: teal,
            size: 18,
          ),

          const SizedBox(width: 8),

          const Text(
            'Kullanılabilir bakiye',
            style: TextStyle(color: muted, fontSize: 11.5),
          ),

          const Spacer(),

          Text(
            _formatMoney(_selectedAccount.balance),
            style: const TextStyle(
              color: navy,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFFFD5D2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB42318),
            size: 19,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFFB42318),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
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

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

class _TurkishMoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final originalText = newValue.text;

    final rawCursor = newValue.selection.baseOffset < 0
        ? originalText.length
        : newValue.selection.baseOffset.clamp(0, originalText.length).toInt();

    final originalCommaIndex = originalText.indexOf(',');

    final cursorIsInDecimals =
        originalCommaIndex >= 0 && rawCursor > originalCommaIndex;

    String integerPart;
    String decimalPart;

    if (originalCommaIndex >= 0) {
      integerPart = originalText
          .substring(0, originalCommaIndex)
          .replaceAll(RegExp(r'[^0-9]'), '');

      decimalPart = originalText
          .substring(originalCommaIndex + 1)
          .replaceAll(RegExp(r'[^0-9]'), '');
    } else {
      integerPart = originalText.replaceAll(RegExp(r'[^0-9]'), '');

      decimalPart = '';
    }

    integerPart = integerPart.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    if (integerPart.isEmpty) {
      integerPart = '0';
    }

    if (decimalPart.length > 2) {
      decimalPart = decimalPart.substring(0, 2);
    }

    final displayedDecimals = decimalPart.padRight(2, '0');

    final formattedInteger = _groupInteger(integerPart);

    final formattedText = '$formattedInteger,$displayedDecimals';

    int newCursorOffset;

    if (cursorIsInDecimals) {
      final decimalTextBeforeCursor = originalText.substring(
        originalCommaIndex + 1,
        rawCursor,
      );

      final decimalDigitsBeforeCursor = RegExp(r'\d')
          .allMatches(decimalTextBeforeCursor)
          .length;

      final decimalOffset = decimalDigitsBeforeCursor > 2
          ? 2
          : decimalDigitsBeforeCursor;

      newCursorOffset = formattedInteger.length + 1 + decimalOffset;
    } else {
      final textBeforeCursor = originalText.substring(0, rawCursor);

      final integerDigitsBeforeCursor = RegExp(r'\d')
          .allMatches(textBeforeCursor)
          .length;

      newCursorOffset = _cursorAfterDigitCount(
        formattedInteger,
        integerDigitsBeforeCursor,
      );
    }

    if (newCursorOffset > formattedText.length) {
      newCursorOffset = formattedText.length;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }

  static String formatValue(double value) {
    final parts = value.toStringAsFixed(2).split('.');

    final integer = _groupInteger(parts[0]);

    return '$integer,${parts[1]}';
  }

  static String _groupInteger(String digits) {
    final clean = digits.replaceAll(RegExp(r'[^0-9]'), '');

    if (clean.isEmpty) {
      return '0';
    }

    final buffer = StringBuffer();

    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && (clean.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(clean[i]);
    }

    return buffer.toString();
  }

  static int _cursorAfterDigitCount(String formattedInteger, int digitCount) {
    if (digitCount <= 0) {
      return 0;
    }

    int seenDigits = 0;

    for (int i = 0; i < formattedInteger.length; i++) {
      final character = formattedInteger[i];

      if (RegExp(r'\d').hasMatch(character)) {
        seenDigits++;

        if (seenDigits == digitCount) {
          return i + 1;
        }
      }
    }

    return formattedInteger.length;
  }
}
