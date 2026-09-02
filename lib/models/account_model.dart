class AccountModel {
  final int id;
  final String accountNumber;
  final double balance;
  final int userId;

  const AccountModel({
    required this.id,
    required this.accountNumber,
    required this.balance,
    required this.userId,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as int,
      accountNumber: json['accountNumber'] as String,
      balance: (json['balance'] as num).toDouble(),
      userId: json['userId'] as int,
    );
  }
}
