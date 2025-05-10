class BankAccount {
  final int? id;
  final String? iban;
  final String? cardholderName;
  final String? bankName;
  final int? user;

  BankAccount({
    this.id,
    this.iban,
    this.cardholderName,
    this.bankName,
    this.user,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json["id"],
      iban: json["iban"],
      cardholderName: json["cardholder_name"],
      bankName: json["bank_name"],
      user: json["user"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "iban": iban,
      "cardholder_name": cardholderName,
      "bank_name": bankName,
      "user": user,
    };
  }

  static List<BankAccount> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => BankAccount.fromJson(e)).toList();
  }
}
