# Authentication Feature

This authentication feature is built with Flutter, Cubit (flutter_bloc), Freezed, and Supabase.

## Structure

```
/auth
  /data
    - auth_remote_data_source.dart (Supabase implementation)
    - auth_repository.dart (Repository layer)
    - auth_providers.dart (Dependency injection)
    /models
      - user_model.dart (Freezed model)
  /cubit
    - auth_cubit.dart (State management)
    - auth_state.dart (Freezed union states)
  /presentation
    - sign_in_page.dart
    - sign_up_page.dart
    - forget_password_page.dart
    - auth_widgets.dart (Reusable widgets)
```

## Setup

1. **Initialize Supabase in your main.dart:**
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

2. **Provide AuthCubit to your app:**
```dart
BlocProvider(
  create: (_) => AuthProviders.createAuthCubit(),
  child: YourApp(),
)
```

3. **Add routes to your router:**
```dart
GoRoute(
  path: '/sign-in',
  builder: (context, state) => const SignInPage(),
),
GoRoute(
  path: '/sign-up',
  builder: (context, state) => const SignUpPage(),
),
GoRoute(
  path: '/forgot-password',
  builder: (context, state) => const ForgetPasswordPage(),
),
```

## Features

- ✅ Email/Password authentication
- ✅ Google OAuth (Web & Mobile)
- ✅ Password reset flow (3-step)
- ✅ Session persistence
- ✅ Auth state listening
- ✅ Form validation
- ✅ Error handling with readable messages
- ✅ Responsive design (Web + Mobile)

## Usage

### Sign In
```dart
context.read<AuthCubit>().signIn(
  emailOrPhone: 'user@example.com',
  password: 'password123',
);
```

### Sign Up
```dart
context.read<AuthCubit>().signUp(
  email: 'user@example.com',
  password: 'password123',
  fullName: 'John Doe',
  phone: '+1234567890', // optional
);
```

### Sign Out
```dart
context.read<AuthCubit>().signOut();
```

### Listen to Auth State
```dart
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    return state.maybeWhen(
      authenticated: (user) => HomePage(user: user),
      unauthenticated: () => SignInPage(),
      loading: () => LoadingWidget(),
      error: (message) => ErrorWidget(message: message),
      orElse: () => SignInPage(),
    );
  },
)
```

## States

- `initial` - Initial state
- `loading` - Loading state during async operations
- `authenticated(UserModel)` - User is authenticated
- `unauthenticated` - User is not authenticated
- `error(String)` - Error occurred with message

## Notes

- The UI matches the provided design specifications
- Google OAuth uses redirect on Web and default behavior on Mobile
- Password reset uses magic link (email verification code flow can be added)
- All Supabase errors are mapped to user-friendly messages

