# Affiliate referral — how it works and what it needs

Invitation links look like:

```
https://<portal-domain>/login?ref=6aec150192786050a0a5acc9&accGroupId=6
```

`ref` is the IB referral id and `accGroupId` the account group. They are sent
to `POST /api/user/register` as `$ref` and `$accGroupId`.

## Flow

1. The OS opens the app on an App Link (Android) / Universal Link (iOS).
2. Flutter hands the full URI to `go_router`.
3. The router's top-level `redirect` calls
   `ReferralService.instance.captureFromUri(state.uri)` — this runs for **every**
   navigation, which covers cold start, warm start and in-app navigation.
4. `/login?ref=…` redirects to `/sign-up?…` (pre-existing behaviour, unchanged).
5. The values are persisted, so they survive navigation, closing the app and
   force-stopping it.
6. `SignUpPage` builds the registration payload through
   `ReferralService.applyToRegistrationPayload(...)`.
7. On `done: true` from `/user/register`, `AuthCubit.signUp` clears them. A
   failed registration keeps them.

Everything lives in
[`lib/core/services/referral/referral_service.dart`](../lib/core/services/referral/referral_service.dart).

## Rules the implementation follows

| Rule | Where |
| --- | --- |
| The invitation domain is never hardcoded in Dart — the host is not inspected at all | `captureFromUri` |
| A URI with no referral parameters leaves stored values alone | `captureFromUri` |
| Empty/blank parameters never overwrite stored values | `_normalise` + `_apply` |
| A new link replaces the previous values | `_apply` |
| A partial link keeps the missing half | `_apply` |
| The same link is not processed twice | `_lastProcessedSignature` |
| Referral data is never cleared on screen init or on a failed registration | only `AuthCubit.signUp` on `done: true` calls `clear()` |
| No second storage mechanism | reuses the existing `CacheService` (SharedPreferences) wrapper |
| Keys are omitted when there is no referral | `applyToRegistrationPayload` |

## Platform status

### Android — working

- `android/app/src/main/AndroidManifest.xml` declares an `autoVerify` App Link
  intent-filter for `atm-crm.egytag.com` and `boker.egytag.com`.
- `flutter_deeplinking_enabled = true` was **added**. Without it the intent
  reaches the activity but its path and query never reach `go_router`, so the
  referral parameters were silently dropped. This was the Android gap.

### iOS — working

- `FlutterDeepLinkingEnabled` is `true` in `ios/Runner/Info.plist`.
- `ios/Runner/Runner.entitlements` lists
  `applinks:atm-crm.egytag.com` and `applinks:boker.egytag.com`.

No deep-linking plugin is used on either platform — Flutter's built-in routing
is enough, and adding one would duplicate it.

## External configuration still required

These cannot be done from the Flutter project:

1. **Android** — each declared domain must serve
   `https://<domain>/.well-known/assetlinks.json` containing the
   `com.boker.app` package name and the **release** signing certificate's
   SHA-256 fingerprint. Until then, autoVerify fails and links open in the
   browser instead of the app.
2. **iOS** — each declared domain must serve
   `https://<domain>/.well-known/apple-app-site-association` (JSON, no
   extension, `application/json`, no redirects) listing
   `<TEAM_ID>.com.boker.app` with the `/login*` path.
3. **Apple Developer portal** — the Associated Domains capability must be
   enabled on the App ID, and the provisioning profile regenerated.
4. **A new portal domain** needs: a `<data>` entry in the manifest, an entry in
   `Runner.entitlements`, and both files above on that domain. The Dart side
   needs no change.

## Deferred deep linking — not supported

If the app is **not installed**, tapping an invitation link opens the browser
and the referral parameters are lost. After installing from the store, the app
starts with no link and therefore no referral.

Standard App Links and Universal Links do **not** recover this. They only work
when the app is already installed.

Supporting it would require a deferred-deep-link provider that fingerprints the
pre-install click and replays it on first launch. The dependency list contains
nothing that can do this today (`firebase_dynamic_links` is discontinued).
Minimum additional work:

- add a provider SDK (e.g. AppsFlyer, Adjust, Branch) — a commercial account is
  required in every case;
- configure its link domain alongside the existing App Link / Universal Link
  setup;
- on first launch, read the deferred link and feed its URI into
  `ReferralService.instance.captureFromUri(...)` — the rest of the pipeline
  already works unchanged.

Direct deep linking is unaffected by this gap.

## Tests

`test/features/referral_test.dart` — 22 tests covering capture (any domain,
extra query parameters, partial links, empty values, duplicate delivery),
replacement policy, persistence across a simulated force-stop, the registration
payload (including route-parameter precedence and numeric `accGroupId`), and
the full lifecycle: failed registration keeps the referral, successful
registration clears it, and a later launch with no link sends nothing stale.
