class ExpenseModel {
  final String id;
  final String caseId;
  final String title;
  final double amount;
  final DateTime date;
  final String category; // 'Lawyer Fee', 'Court Fee', 'Travel', 'Other'

  ExpenseModel({
    required this.id,
    required this.caseId,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseModel(
      id: id,
      caseId: map['caseId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      category: map['category'] ?? 'Other',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'caseId': caseId,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    };
  }
}
