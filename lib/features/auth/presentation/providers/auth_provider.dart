import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.value ?? ref.watch(authRepositoryProvider).currentUser;
});

final userProfileStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.data());
});

final userNameProvider = Provider<String>((ref) {
  final profileData = ref.watch(userProfileStreamProvider).value;
  final profileName = profileData?['fullName'] as String?;
  if (profileName != null && profileName.trim().isNotEmpty) {
    return profileName.trim();
  }

  final user = ref.watch(currentUserProvider);
  if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
    return user.displayName!.trim();
  }

  if (user?.email != null && user!.email!.isNotEmpty) {
    final localPart = user.email!.split('@').first;
    return localPart[0].toUpperCase() + localPart.substring(1);
  }

  return 'User';
});
