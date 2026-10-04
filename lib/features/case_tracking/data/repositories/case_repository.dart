import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/case_model.dart';

class CaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'cases';

  // Get cases for a specific user
  Stream<List<CaseModel>> getUserCases(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CaseModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Add a new case
  Future<void> addCase(CaseModel caseModel, String userId) async {
    final data = caseModel.toMap();
    data['userId'] = userId;
    await _firestore.collection(_collection).add(data);
  }

  // Update a case
  Future<void> updateCase(CaseModel caseModel) async {
    await _firestore
        .collection(_collection)
        .doc(caseModel.id)
        .update(caseModel.toMap());
  }

  // Delete a case
  Future<void> deleteCase(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
