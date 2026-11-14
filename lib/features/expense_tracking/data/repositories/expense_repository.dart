import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/expense_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'expenses';
  static final List<ExpenseModel> _inMemoryExpenses = [];
  static final StreamController<List<ExpenseModel>> _localStreamController =
      StreamController<List<ExpenseModel>>.broadcast();
  static StreamSubscription? _firestoreSub;
  static String? _activeUserId;

  void _listenToFirestore(String userId) {
    if (userId.isEmpty || userId == 'guest_user') return;
    if (_activeUserId == userId && _firestoreSub != null) return;
    _activeUserId = userId;
    _firestoreSub?.cancel();

    _firestoreSub = _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      final cloudItems = <ExpenseModel>[];
      for (var doc in snapshot.docs) {
        try {
          cloudItems.add(ExpenseModel.fromMap(doc.data(), doc.id));
        } catch (_) {}
      }

      for (var item in cloudItems) {
        final existingIdx = _inMemoryExpenses.indexWhere((e) =>
            e.id == item.id ||
            (e.title == item.title &&
                (e.amount - item.amount).abs() < 0.01 &&
                e.date.isAtSameMomentAs(item.date)));
        if (existingIdx >= 0) {
          _inMemoryExpenses[existingIdx] = item;
        } else {
          _inMemoryExpenses.add(item);
        }
      }

      _inMemoryExpenses.sort((a, b) => b.date.compareTo(a.date));
      if (!_localStreamController.isClosed) {
        _localStreamController.add(List<ExpenseModel>.from(_inMemoryExpenses));
      }
    }, onError: (_) {
      if (!_localStreamController.isClosed) {
        _localStreamController.add(List<ExpenseModel>.from(_inMemoryExpenses));
      }
    });
  }

  Stream<List<ExpenseModel>> getUserExpenses(String userId) async* {
    _listenToFirestore(userId);
    yield List<ExpenseModel>.from(_inMemoryExpenses);
    yield* _localStreamController.stream;
  }

  Future<void> addExpense(ExpenseModel expense, String userId) async {
    final generatedId = expense.id.isNotEmpty
        ? expense.id
        : DateTime.now().millisecondsSinceEpoch.toString();

    final modelWithId = ExpenseModel(
      id: generatedId,
      caseId: expense.caseId,
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      category: expense.category,
    );

    _inMemoryExpenses.removeWhere((e) => e.id == generatedId);
    _inMemoryExpenses.insert(0, modelWithId);
    _inMemoryExpenses.sort((a, b) => b.date.compareTo(a.date));
    if (!_localStreamController.isClosed) {
      _localStreamController.add(List<ExpenseModel>.from(_inMemoryExpenses));
    }

    if (userId.isNotEmpty && userId != 'guest_user') {
      final data = expense.toMap();
      data['userId'] = userId;
      _firestore.collection(_collection).add(data).timeout(const Duration(seconds: 4)).then((docRef) {
        final idx = _inMemoryExpenses.indexWhere((e) => e.id == generatedId);
        if (idx >= 0) {
          _inMemoryExpenses[idx] = ExpenseModel(
            id: docRef.id,
            caseId: modelWithId.caseId,
            title: modelWithId.title,
            amount: modelWithId.amount,
            date: modelWithId.date,
            category: modelWithId.category,
          );
          if (!_localStreamController.isClosed) {
            _localStreamController.add(List<ExpenseModel>.from(_inMemoryExpenses));
          }
        }
      }).catchError((_) {
        // In-memory version remains preserved for UI
      });
    }
  }
}
