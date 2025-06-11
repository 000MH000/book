import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// ** THE FIX: Corrected the import path from '.' to ':' **
import 'package:mobile_app_project_bookstore/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:mobile_app_project_bookstore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile_app_project_bookstore/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_app_project_bookstore/features/user_profile/presentation/providers/user_profile_providers.dart';

part 'auth_providers.g.dart';

@riverpod
FirebaseAuthDataSource firebaseAuthDataSource(FirebaseAuthDataSourceRef ref) {
  return FirebaseAuthDataSource(FirebaseAuth.instance);
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(dataSource: ref.watch(firebaseAuthDataSourceProvider));
}

@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@riverpod
class AuthController extends _$AuthController {
  @override
  Future<void> build() async {}

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      return _authRepository.signInWithEmailAndPassword(email, password);
    });
  }

  Future<void> signUpAndCreateProfile({
    required String email,
    required String password,
    required String displayName,
    required List<String> favoriteGenres,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userCredential = await _authRepository.createUserWithEmailAndPassword(email, password);

      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await ref.read(userProfileRepositoryProvider).createUserProfile(
          uid: user.uid,
          email: email,
          displayName: displayName,
          favoriteGenres: favoriteGenres,
        );
      }
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_authRepository.signOut);
  }
}
