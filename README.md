# Boker — Flutter Client Portal

Mobile client portal for the Boker brokerage platform (Android and iOS). It is
the mobile counterpart of the Boker Web Client Portal and talks to the same
backend: accounts, deposits/withdrawals/transfers, payment methods, MT5 data,
IB dashboard, KYC verification, agreements, support messaging, help-desk
tickets and notifications.

- **Backend (production):** `https://atm-crm.egytag.com`
- **Flutter:** 3.47.x · **Dart:** 3.13.x (SDK constraint `^3.10.4`)
- **State management:** `flutter_bloc` (Cubits) · **DI:** `get_it`
- **Routing:** `go_router` · **Networking:** `dio`
- **Localization:** `easy_localization` (English + Arabic)

---

## 1. Setup

```bash
flutter pub get
```

The project has no local path dependencies, so a fresh clone builds on any
machine.

Code generation (`freezed` / `json_serializable`) — only needed after changing
a `@freezed` state or an annotated model:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run the app:

```bash
flutter run
```

Static analysis and tests:

```bash
flutter analyze
```

```bash
flutter test
```

---

## 2. Environment configuration

All API hosts resolve through a single class: `lib/core/config/env/app_config.dart`.
No service contains a hardcoded host.

| Environment   | How to select it                              |
| ------------- | --------------------------------------------- |
| `production`  | default (no flags)                            |
| `staging`     | `--dart-define=BOKER_ENV=staging`             |
| `development` | `--dart-define=BOKER_ENV=development`         |

`BOKER_BASE_URL` overrides the host for the selected environment:

```bash
flutter run \
  --dart-define=BOKER_ENV=development \
  --dart-define=BOKER_BASE_URL=http://10.0.2.2:3000
```

Only the production host is baked in. Development and staging fall back to it
until you point them somewhere with `BOKER_BASE_URL` — deliberately, so a build
can never silently talk to a host that does not exist.

`AppConfig` also derives:

- `apiBaseUrl` → `<baseUrl>/api`
- `uploadBaseUrl` → `<baseUrl>/x-api/upload`
- `enableNetworkLogging` → `false` in production (request/response logging is
  off, and credential-bearing headers are redacted even in debug builds)

Endpoint paths live in `lib/core/data/constants/apis_constants.dart`.

---

## 3. Authentication & session

The backend authenticates with an `access_token` cookie.

- `SessionManager` (`lib/core/network/dio/session_manager.dart`) is the single
  source of truth. The token is held in memory (so interceptors read it
  synchronously) and mirrored into `flutter_secure_storage`.
- `AuthInterceptor` attaches the **current** token to every request on every
  `Dio` instance, and never writes an empty cookie.
- **There is no refresh endpoint on this backend.** A `401` therefore clears the
  session once (concurrent 401s collapse into one teardown), never retries the
  failing request, and routes back to the login screen.
- Login endpoints (`/user/login`, `/user/register`, …) are exempt from the 401
  teardown so bad credentials surface as a form error.

Password rules are defined once in `lib/core/utils/password_policy.dart` and
reused by registration, change-password and reset-password: at least 8
characters with one uppercase, one lowercase, one number and one special
character.

---

## 4. Notifications & push

- **Notifications Center** — `lib/features/notifications/`: list with search,
  unread-only filter, `limit`/`skip` pagination, pull-to-refresh, mark (all) as
  read, delete (all), and validated navigation from a notification to its
  in-app destination.
- **Live counters** — `POST /api/notifications/summary`, kept current while the
  app is in the foreground by the `GET /api/activity/stream` SSE endpoint
  (`counts`, `notification`, `message-new`), with capped exponential-backoff
  reconnects.
- **Push (FCM)** — `lib/core/services/notifications/`.

### Enabling push notifications

Firebase config files are **not** in the repository. Without them the app still
builds and runs; push is simply inactive (`PushNotificationsService.isAvailable`
is `false`, and the settings screen says so instead of showing a dead switch).

To enable push:

1. Add `android/app/google-services.json`.
2. Add `ios/Runner/GoogleService-Info.plist`.
3. Rebuild. The Gradle `google-services` plugin is applied automatically when
   the JSON file is present.

The app registers its FCM token with `POST /api/notifications/device/register`
after sign-in and on token refresh, and unregisters on sign-out.

> The **server** also needs its own Firebase Admin service credentials
> configured before it will actually send anything. Registering a device token
> from the app does not by itself enable delivery.

---

## 5. Android release build

`android/app/build.gradle.kts`:

- `applicationId` / `namespace`: `com.boker.app`
- Release builds are **never** signed with the debug keys.

Signing credentials are read, in order of precedence, from:

1. `android/key.properties` (git-ignored — see `android/key.properties.example`)
2. Environment variables, for CI:
   - `BOKER_KEYSTORE_PATH`
   - `BOKER_KEYSTORE_PASSWORD`
   - `BOKER_KEY_ALIAS`
   - `BOKER_KEY_PASSWORD`

With no credentials available the release build is produced **unsigned** (and
Gradle logs a warning), so it can still be signed later or handed to Play App
Signing.

```bash
flutter build appbundle --release
```

```bash
flutter build apk --release
```

iOS bundle identifier is `com.boker.app`.

---

## 6. Orientation

The app is portrait-only on both platforms: locked in `lib/main.dart` and
matched by `ios/Runner/Info.plist` (iPhone **and** iPad). The UI is laid out
against a 375×812 portrait design through the vendored responsive helper.

---

## 7. Project layout

```
lib/
├── core/
│   ├── componants/        # shared widgets
│   ├── config/
│   │   ├── env/           # AppConfig — environment + hosts
│   │   ├── local/         # shared_preferences + secure storage
│   │   ├── routes/        # go_router configuration
│   │   └── theme/
│   ├── data/constants/    # ApiConstants — endpoint paths
│   ├── di/                # get_it registrations
│   ├── errors/
│   ├── network/dio/       # DioFactory, AuthInterceptor, SessionManager
│   ├── packages/          # vendored third-party sources (see below)
│   ├── services/          # uploads, notifications bootstrap, FCM
│   └── utils/
└── features/
    ├── accounts/          # real + demo accounts, creation
    ├── auth/              # sign in/up, email OTP, KYC submission
    ├── home/              # dashboard, wallet card, transaction history
    ├── ib_dashboard/
    ├── layout/            # shell, bottom nav, drawer
    ├── mt5_data/
    ├── notifications/     # Notifications Center
    ├── onboarding/
    ├── payment_methods/
    ├── profile/           # profile, settings, verification, agreements,
    │                      # support chat, help-desk tickets
    └── transactions/      # deposit / withdraw / transfer, MyFatoorah
```

Each feature follows `data/{models,data_source,repositories}` +
`presentation/{cubit,pages,widgets}`.

### Vendored packages

`lib/core/packages/` holds third-party sources that are kept in-tree:

- `res_reline/` — responsive sizing (`.w`, `.h`, `.s`, `.r`, `ResInit`). It used
  to be a `path:` dependency on a local folder, which made the project
  unbuildable on any other machine.
- `dropdown_search/` — searchable dropdown.

Both are excluded from `flutter analyze` in `analysis_options.yaml` so their
lints do not drown out the project's own.

---

## 8. Dependencies

| Package                                       | Purpose                       |
| --------------------------------------------- | ----------------------------- |
| `flutter_bloc`, `bloc`                        | state management              |
| `get_it`                                      | dependency injection          |
| `go_router`                                   | routing                       |
| `dio`, `pretty_dio_logger`                    | HTTP + logging (non-prod)     |
| `freezed_annotation`, `json_annotation`       | immutable state / models      |
| `equatable`                                   | value equality                |
| `dartz`-style `Either` (in `core/errors`)     | error handling                |
| `flutter_secure_storage`, `shared_preferences`| session + preferences         |
| `easy_localization`                           | en / ar                       |
| `firebase_core`, `firebase_messaging`         | push notifications            |
| `flutter_local_notifications`                 | foreground notifications      |
| `file_picker`, `image_picker`                 | document / receipt upload     |
| `url_launcher`                                | payment pages, documents      |
| `package_info_plus`                           | real app version              |
| `intl`, `jiffy`                               | dates                         |
| `cached_network_image`, `shimmer`             | images, loading states        |
| `flutter_credit_card`                         | card entry UI                 |
| `local_auth`                                  | biometrics                    |
| `device_preview`                              | **debug builds only**         |

Dev: `flutter_lints`, `freezed`, `build_runner`, `json_serializable`,
`bloc_test`, `mocktail`.

The git dependency `intl_phone_field` is pinned to a commit
(`224fdd86c56efd13d6eacc4077ed9269bb99aa18`) rather than tracking `HEAD`.

---

## 9. Testing

```bash
flutter test
```

Tests use `mocktail` against controlled responses — no production credentials
and no network access are required.

| File                                             | Covers                                                        |
| ------------------------------------------------ | ------------------------------------------------------------- |
| `test/core/session_and_auth_test.dart`           | environment config, session cookie, 401 handling, password policy |
| `test/features/accounts/accounts_test.dart`      | account parsing, `code` vs `id` display, MT5 details, creation |
| `test/features/transactions/transactions_test.dart` | transaction payloads, MyFatoorah quote, gateway redirect, deposit validation, history filters |
| `test/features/notifications/notifications_test.dart` | list/pagination/read/delete, summary counters, notification routing |
| `test/features/messages_and_stream_test.dart`    | message parsing, failed-send retry, SSE decoding               |

---

## 10. Affiliate referral

Invitation links (`https://<portal-domain>/login?ref=…&accGroupId=…`) are
captured by `ReferralService`, persisted across restarts, sent to
`/user/register` as `$ref` / `$accGroupId`, and cleared only after the account
is created. See [`docs/AFFILIATE_REFERRAL.md`](docs/AFFILIATE_REFERRAL.md) for
the platform setup and the external configuration each portal domain needs.

## 11. Known backend limitations

See [`docs/BACKEND_GAPS.md`](docs/BACKEND_GAPS.md) for the capabilities the app
needs that the backend does not currently expose, and how each is handled.
