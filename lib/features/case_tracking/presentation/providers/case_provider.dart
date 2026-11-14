import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haqdaar/features/auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/case_repository.dart';
import '../../data/repositories/hearing_repository.dart';
import '../../domain/models/case_model.dart';
import '../../domain/models/hearing_model.dart';

final caseRepositoryProvider = Provider<CaseRepository>((ref) {
  return CaseRepository();
});

final hearingRepositoryProvider = Provider<HearingRepository>((ref) {
  return HearingRepository();
});

final casesStreamProvider = StreamProvider<List<CaseModel>>((ref) {
  final repository = ref.watch(caseRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final uid = user?.uid ?? 'guest_user';
  return repository.getUserCases(uid);
});

final hearingsStreamProvider = StreamProvider<List<HearingModel>>((ref) {
  final repository = ref.watch(hearingRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final uid = user?.uid ?? 'guest_user';
  return repository.getUserHearings(uid);
});
