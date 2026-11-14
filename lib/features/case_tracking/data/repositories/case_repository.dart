import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/case_model.dart';

class CaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'cases';
  static final List<CaseModel> _inMemoryCases = [
    CaseModel(
      id: '1',
      title: 'Property Dispute - Katchery',
      description: 'Dispute over land boundaries with neighbor',
      status: 'Active',
      nextHearingDate: DateTime.now().add(const Duration(days: 14)),
      courtName: 'Civil Court, Lahore',
      lawyerName: 'Adv. Ahmed Khan',
    ),
    CaseModel(
      id: '2',
      title: 'Tenant Eviction (Bedakhli)',
      description: 'Filing eviction against tenant for non-payment of rent',
      status: 'Pending',
      nextHearingDate: DateTime.now().add(const Duration(days: 5)),
      courtName: 'Rent Tribunal',
      lawyerName: 'Adv. Sarah Ali',
    ),
  ];
  static final StreamController<List<CaseModel>> _localCasesController =
      StreamController<List<CaseModel>>.broadcast();
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
      final cloudItems = <CaseModel>[];
      for (var doc in snapshot.docs) {
        try {
          cloudItems.add(CaseModel.fromMap(doc.data(), doc.id));
        } catch (_) {}
      }

      for (var item in cloudItems) {
        final existingIdx = _inMemoryCases.indexWhere((c) =>
            c.id == item.id ||
            (c.title == item.title && c.courtName == item.courtName));
        if (existingIdx >= 0) {
          _inMemoryCases[existingIdx] = item;
        } else {
          _inMemoryCases.add(item);
        }
      }

      if (!_localCasesController.isClosed) {
        _localCasesController.add(List<CaseModel>.from(_inMemoryCases));
      }
    }, onError: (_) {
      if (!_localCasesController.isClosed) {
        _localCasesController.add(List<CaseModel>.from(_inMemoryCases));
      }
    });
  }

  Stream<List<CaseModel>> getUserCases(String userId) async* {
    _listenToFirestore(userId);
    yield List<CaseModel>.from(_inMemoryCases);
    yield* _localCasesController.stream;
  }

  Future<void> addCase(CaseModel caseModel, String userId) async {
    final generatedId = caseModel.id.isNotEmpty
        ? caseModel.id
        : DateTime.now().millisecondsSinceEpoch.toString();

    final modelWithId = CaseModel(
      id: generatedId,
      title: caseModel.title,
      description: caseModel.description,
      status: caseModel.status,
      nextHearingDate: caseModel.nextHearingDate,
      courtName: caseModel.courtName,
      lawyerName: caseModel.lawyerName,
    );

    _inMemoryCases.removeWhere((c) => c.id == generatedId);
    _inMemoryCases.insert(0, modelWithId);
    if (!_localCasesController.isClosed) {
      _localCasesController.add(List<CaseModel>.from(_inMemoryCases));
    }

    if (userId.isNotEmpty && userId != 'guest_user') {
      final data = caseModel.toMap();
      data['userId'] = userId;
      _firestore.collection(_collection).add(data).timeout(const Duration(seconds: 4)).then((docRef) {
        final idx = _inMemoryCases.indexWhere((c) => c.id == generatedId);
        if (idx >= 0) {
          _inMemoryCases[idx] = CaseModel(
            id: docRef.id,
            title: modelWithId.title,
            description: modelWithId.description,
            status: modelWithId.status,
            nextHearingDate: modelWithId.nextHearingDate,
            courtName: modelWithId.courtName,
            lawyerName: modelWithId.lawyerName,
          );
          if (!_localCasesController.isClosed) {
            _localCasesController.add(List<CaseModel>.from(_inMemoryCases));
          }
        }
      }).catchError((_) {});
    }
  }

  Future<void> updateCase(CaseModel caseModel) async {
    final idx = _inMemoryCases.indexWhere((c) => c.id == caseModel.id);
    if (idx >= 0) {
      _inMemoryCases[idx] = caseModel;
      if (!_localCasesController.isClosed) {
        _localCasesController.add(List<CaseModel>.from(_inMemoryCases));
      }
    }
    try {
      await _firestore
          .collection(_collection)
          .doc(caseModel.id)
          .update(caseModel.toMap())
          .timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  Future<void> deleteCase(String id) async {
    _inMemoryCases.removeWhere((c) => c.id == id);
    if (!_localCasesController.isClosed) {
      _localCasesController.add(List<CaseModel>.from(_inMemoryCases));
    }
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .delete()
          .timeout(const Duration(seconds: 4));
    } catch (_) {}
  }
}
