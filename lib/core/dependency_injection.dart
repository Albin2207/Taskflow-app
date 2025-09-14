import 'package:get_it/get_it.dart';
import '../data/database/local/database_helper.dart' show DatabaseHelper;
import '../data/database/local/user_database.dart';
import '../data/database/services/firebase_auth_service.dart';
import '../data/repositories/auth_repositories.dart';
import '../data/repositories/user_repositories.dart';
import '../domain/repositories/auth_repositories.dart';
import '../domain/repositories/user_repositories.dart';
import '../domain/usecases/get_user_case.dart';
import '../domain/usecases/sign_in_case.dart';
import '../domain/usecases/sign_out_case.dart';
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/user/user_bloc.dart';



final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton<DatabaseHelper>(
    () => DatabaseHelper.instance,
  );

  // Data Sources
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(),
  );

  sl.registerLazySingleton<LocalUserDataSource>(
    () => LocalUserDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => SignInUseCase(sl(), sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetUserUseCase(sl(), sl()));

  // BLoC
  sl.registerFactory(() => AuthBloc(
        signInUseCase: sl(),
        signOutUseCase: sl(),
        authRepository: sl(),
      ));

  sl.registerFactory(() => UserBloc(getUserUseCase: sl()));
}