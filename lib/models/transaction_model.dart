class TransactionModel {
  final int id;
  final String type;
  final String direction;
  final double amount;
  final int accountId;
  final int? targetAccountId;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.direction,
    required this.amount,
    required this.accountId,
    required this.targetAccountId,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      type: json['type'] as String,
      direction: json['direction'] as String,
      amount: (json['amount'] as num).toDouble(),
      accountId: json['accountId'] as int,
      targetAccountId: json['targetAccountId'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool get isIncoming => direction == 'INCOMING';
}
