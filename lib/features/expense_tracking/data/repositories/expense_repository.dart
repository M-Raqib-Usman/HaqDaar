import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/expense_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'expenses';

  Stream<List<ExpenseModel>> getUserExpenses(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addExpense(ExpenseModel expense, String userId) async {
    final data = expense.toMap();
    data['userId'] = userId;
    await _firestore.collection(_collection).add(data);
  }
}
