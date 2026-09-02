class RecipientModel {
  final String accountNumber;
  final String fullName;

  const RecipientModel({required this.accountNumber, required this.fullName});

  factory RecipientModel.fromJson(Map<String, dynamic> json) {
    return RecipientModel(
      accountNumber: json['accountNumber'] as String,
      fullName: json['fullName'] as String,
    );
  }
}
