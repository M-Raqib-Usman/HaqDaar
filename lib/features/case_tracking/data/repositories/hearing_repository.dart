import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/hearing_model.dart';

class HearingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'hearings';
  static final List<HearingModel> _inMemoryHearings = [];
  static final StreamController<List<HearingModel>> _localHearingsController =
      StreamController<List<HearingModel>>.broadcast();
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
      final cloudItems = <HearingModel>[];
      for (var doc in snapshot.docs) {
        try {
          cloudItems.add(HearingModel.fromMap(doc.data(), doc.id));
        } catch (_) {}
      }

      for (var item in cloudItems) {
        final existingIdx = _inMemoryHearings.indexWhere((h) =>
            h.id == item.id ||
            (h.title == item.title &&
                h.hearingDate.isAtSameMomentAs(item.hearingDate)));
        if (existingIdx >= 0) {
          _inMemoryHearings[existingIdx] = item;
        } else {
          _inMemoryHearings.add(item);
        }
      }

      _inMemoryHearings.sort((a, b) => a.hearingDate.compareTo(b.hearingDate));
      if (!_localHearingsController.isClosed) {
        _localHearingsController.add(List<HearingModel>.from(_inMemoryHearings));
      }
    }, onError: (_) {
      if (!_localHearingsController.isClosed) {
        _localHearingsController.add(List<HearingModel>.from(_inMemoryHearings));
      }
    });
  }

  Stream<List<HearingModel>> getUserHearings(String userId) async* {
    _listenToFirestore(userId);
    yield List<HearingModel>.from(_inMemoryHearings);
    yield* _localHearingsController.stream;
  }

  Future<void> addHearing(HearingModel hearing, String userId) async {
    final generatedId = hearing.id.isNotEmpty
        ? hearing.id
        : DateTime.now().millisecondsSinceEpoch.toString();

    final modelWithId = HearingModel(
      id: generatedId,
      title: hearing.title,
      courtName: hearing.courtName,
      hearingDate: hearing.hearingDate,
      hearingTime: hearing.hearingTime,
      caseId: hearing.caseId,
      notes: hearing.notes,
    );

    _inMemoryHearings.removeWhere((h) => h.id == generatedId);
    _inMemoryHearings.add(modelWithId);
    _inMemoryHearings.sort((a, b) => a.hearingDate.compareTo(b.hearingDate));
    if (!_localHearingsController.isClosed) {
      _localHearingsController.add(List<HearingModel>.from(_inMemoryHearings));
    }

    if (userId.isNotEmpty && userId != 'guest_user') {
      final data = hearing.toMap();
      data['userId'] = userId;
      _firestore.collection(_collection).add(data).timeout(const Duration(seconds: 4)).then((docRef) {
        final idx = _inMemoryHearings.indexWhere((h) => h.id == generatedId);
        if (idx >= 0) {
          _inMemoryHearings[idx] = HearingModel(
            id: docRef.id,
            title: modelWithId.title,
            courtName: modelWithId.courtName,
            hearingDate: modelWithId.hearingDate,
            hearingTime: modelWithId.hearingTime,
            caseId: modelWithId.caseId,
            notes: modelWithId.notes,
          );
          if (!_localHearingsController.isClosed) {
            _localHearingsController.add(List<HearingModel>.from(_inMemoryHearings));
          }
        }
      }).catchError((_) {});
    }
  }

  Future<void> deleteHearing(String id) async {
    _inMemoryHearings.removeWhere((h) => h.id == id);
    if (!_localHearingsController.isClosed) {
      _localHearingsController.add(List<HearingModel>.from(_inMemoryHearings));
    }
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (_) {}
  }
}
