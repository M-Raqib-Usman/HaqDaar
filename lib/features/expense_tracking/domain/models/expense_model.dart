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
    DateTime parsedDate;
    final d = map['date'];
    if (d is DateTime) {
      parsedDate = d;
    } else if (d != null && d.runtimeType.toString().contains('Timestamp')) {
      parsedDate = (d as dynamic).toDate();
    } else if (d is String) {
      parsedDate = DateTime.tryParse(d) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final rawAmount = map['amount'];
    double parsedAmount = 0.0;
    if (rawAmount is num) {
      parsedAmount = rawAmount.toDouble();
    } else if (rawAmount is String) {
      parsedAmount = double.tryParse(rawAmount) ?? 0.0;
    }

    return ExpenseModel(
      id: id,
      caseId: map['caseId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      amount: parsedAmount,
      date: parsedDate,
      category: map['category']?.toString() ?? 'Other',
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
