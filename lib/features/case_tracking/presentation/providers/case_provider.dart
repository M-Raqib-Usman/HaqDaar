import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/case_repository.dart';
import '../../domain/models/case_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

final caseRepositoryProvider = Provider<CaseRepository>((ref) {
  return CaseRepository();
});

final casesStreamProvider = StreamProvider<List<CaseModel>>((ref) {
  final repository = ref.watch(caseRepositoryProvider);
  final user = FirebaseAuth.instance.currentUser;
  
  if (user != null) {
    return repository.getUserCases(user.uid);
  } else {
    // For mockup purposes, return an empty stream or a mock stream if no user is logged in
    return Stream.value([
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
    ]);
  }
});
