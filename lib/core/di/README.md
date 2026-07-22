# Dependency Injection (DI)

This directory contains the dependency injection setup using **Factory Pattern** (not singleton).

## Structure

- `dependency_injection.dart` - Main DI container with factory methods

## Usage

### Basic Usage

```dart
import 'package:boker/core/di/dependency_injection.dart';

// Create Auth Cubit
final authCubit = DependencyInjection.createAuthCubit();

// Create Auth Repository
final authRepository = DependencyInjection.createAuthRepository();

// Create Auth Remote Data Source
final remoteDataSource = DependencyInjection.createAuthRemoteDataSource();
```

### In BlocProvider

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boker/core/di/dependency_injection.dart';
import 'package:boker/features/auth/cubit/auth_cubit.dart';

BlocProvider<AuthCubit>(
  create: (_) => DependencyInjection.createAuthCubit(),
  child: YourWidget(),
)
```

### In MultiBlocProvider

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<AuthCubit>(
      create: (_) => DependencyInjection.createAuthCubit(),
    ),
    // Add more providers here
  ],
  child: YourApp(),
)
```

## Factory Pattern

Each factory method creates a **new instance** every time it's called. This means:

- ✅ No shared state between instances
- ✅ Easy to test (can create fresh instances)
- ✅ No singleton issues
- ✅ Thread-safe

## Example: Creating Multiple Instances

```dart
// Each call creates a new instance
final cubit1 = DependencyInjection.createAuthCubit();
final cubit2 = DependencyInjection.createAuthCubit();

// cubit1 != cubit2 (different instances)
```

## Adding New Dependencies

To add new dependencies, follow this pattern:

```dart
class DependencyInjection {
  // 1. Add factory method for data source
  static YourRemoteDataSource createYourRemoteDataSource() {
    return YourRemoteDataSourceImpl(
      supabase: supabaseClient,
    );
  }

  // 2. Add factory method for repository
  static YourRepository createYourRepository() {
    final dataSource = createYourRemoteDataSource();
    return YourRepositoryImpl(dataSource: dataSource);
  }

  // 3. Add factory method for cubit/bloc
  static YourCubit createYourCubit() {
    final repository = createYourRepository();
    return YourCubit(repository: repository);
  }
}
```

## Notes

- Supabase client is accessed via `Supabase.instance.client` (this is a singleton from Supabase SDK)
- All other dependencies use factory pattern (new instance each time)
- Dependencies are created on-demand (lazy initialization)

