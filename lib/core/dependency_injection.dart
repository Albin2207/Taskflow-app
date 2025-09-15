import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../data/database/local/database_helper.dart' show DatabaseHelper;
import '../data/database/local/user_database.dart';
import '../data/database/services/api_service.dart';
import '../data/database/services/firebase_auth_service.dart';
import '../data/repositories/api_user_repositories.dart';
import '../data/repositories/auth_repositories.dart';
import '../data/repositories/user_repositories.dart';
import '../domain/repositories/api_user_repositories.dart';
import '../domain/repositories/auth_repositories.dart';
import '../domain/repositories/user_repositories.dart';
import '../domain/usecases/get_user_case.dart';
import '../domain/usecases/sign_in_case.dart';
import '../domain/usecases/sign_out_case.dart';
import '../domain/usecases/userslist_usecases.dart';
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/connectivity/connectivity_bloc.dart';
import '../presentation/bloc/userlist/userlist_bloc.dart';
import '../presentation/bloc/userprofile/user_bloc.dart';
import 'connectivity_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = 'https://reqres.in/api';
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // Add the API key header for all requests
    dio.options.headers['x-api-key'] = 'reqres-free-v1';
    
    return dio;
  });

  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  // Data Sources
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(),
  );

  sl.registerLazySingleton<LocalUserDataSource>(
    () => LocalUserDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ApiDataSource>(() => ApiDataSourceImpl(dio: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));

  sl.registerLazySingleton<ApiUsersRepository>(
    () => ApiUsersRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => SignInUseCase(sl(), sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetUserUseCase(sl(), sl()));

  // API Users Use Cases
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUserUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl(),
      signOutUseCase: sl(),
      authRepository: sl(),
    ),
  );

  sl.registerFactory(() => UserBloc(getUserUseCase: sl()));

  sl.registerFactory(
    () => UsersBloc(
      getUsersUseCase: sl(),
      createUserUseCase: sl(),
      updateUserUseCase: sl(),
      deleteUserUseCase: sl(),
    ),
  );

  sl.registerFactory(() => ConnectivityBloc(connectivityService: sl()));
}