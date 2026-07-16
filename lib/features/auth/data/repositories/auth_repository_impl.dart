import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> signInWithGoogle() async =>
      await remoteDataSource.signInWithGoogle();

  @override
  Future<UserEntity> signInWithFacebook() async =>
      await remoteDataSource.signInWithFacebook();

  @override
  Future<void> signOut() async => await remoteDataSource.signOut();

  @override
  Future<UserEntity?> getCurrentUser() async =>
      await remoteDataSource.getCurrentUser();
}
