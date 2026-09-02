class TransactionModel {
  final int id;
  final String type;
  final String direction;
  final double amount;

  final int accountId;
  final String? accountNumber;
  final String? accountHolderName;

  final int? targetAccountId;
  final String? targetAccountNumber;
  final String? targetAccountHolderName;

  final double? balanceAfter;

  final String description;
  final String channel;
  final String status;

  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.direction,
    required this.amount,
    required this.accountId,
    required this.accountNumber,
    required this.accountHolderName,
    required this.targetAccountId,
    required this.targetAccountNumber,
    required this.targetAccountHolderName,
    required this.balanceAfter,
    required this.description,
    required this.channel,
    required this.status,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,

      type: json['type'] as String,

      direction: json['direction'] as String,

      amount: (json['amount'] as num).toDouble(),

      accountId: json['accountId'] as int,

      accountNumber: json['accountNumber'] as String?,

      accountHolderName: json['accountHolderName'] as String?,

      targetAccountId: json['targetAccountId'] as int?,

      targetAccountNumber: json['targetAccountNumber'] as String?,

      targetAccountHolderName: json['targetAccountHolderName'] as String?,

      balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),

      description: json['description']?.toString() ?? 'IBT Bank işlemi',

      channel: json['channel']?.toString() ?? 'IBT Mobil',

      status: json['status']?.toString() ?? 'COMPLETED',

      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool get isIncoming => direction == 'INCOMING';

  bool get isTransfer => type == 'TRANSFER';
}
