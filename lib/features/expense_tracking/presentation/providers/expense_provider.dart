import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/expense_repository.dart';
import '../../domain/models/expense_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

final expensesStreamProvider = StreamProvider<List<ExpenseModel>>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  final user = FirebaseAuth.instance.currentUser;
  
  if (user != null) {
    return repository.getUserExpenses(user.uid);
  } else {
    // Return mock data if not logged in
    return Stream.value([
      ExpenseModel(
        id: '1',
        caseId: '1',
        title: 'Initial Lawyer Consultation',
        amount: 15000,
        date: DateTime.now().subtract(const Duration(days: 10)),
        category: 'Lawyer Fee',
      ),
      ExpenseModel(
        id: '2',
        caseId: '1',
        title: 'Court Filing Fee (Ticket)',
        amount: 500,
        date: DateTime.now().subtract(const Duration(days: 5)),
        category: 'Court Fee',
      ),
    ]);
  }
});
