import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haqdaar/features/auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/expense_repository.dart';
import '../../domain/models/expense_model.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

final expensesStreamProvider = StreamProvider<List<ExpenseModel>>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final uid = user?.uid ?? 'guest_user';
  return repository.getUserExpenses(uid);
});
