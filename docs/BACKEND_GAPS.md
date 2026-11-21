# Backend capabilities the app needs but cannot use

Each item below was verified against the live backend
(`https://atm-crm.egytag.com`) by probing the endpoint. `401 Require
Permissions` means the route exists but needs a session; `404` means it does
not exist. No endpoint has been invented anywhere in the app.

| # | Capability | Verified result | How the app handles it |
|---|------------|-----------------|------------------------|
| 1 | **Token refresh** | `/api/auth/refresh`, `/api/user/refresh`, `/api/user/refresh-token`, `/api/user/refreshToken`, `/api/token/refresh` → **404** | No refresh is attempted. A `401` clears the session once and routes to login; the failing request is never retried, so no retry loop is possible. |
| 2 | **Phone / SMS authentication** | `/api/store/auth/phone/request-otp`, `/api/auth/phone/request-otp`, `/api/user/sendOtp`, `/api/user/verify-phone-otp` → **404** | The phone-login entry point and its OTP screen were removed from sign-in. `requestPhoneLoginOtp`, `verifyPhoneLoginOtp`, `verifyOtp` and `resendOtp` return an explicit "not available" failure instead of throwing `UnimplementedError`. If the login response ever sets `requires_phone_verification`, the user is told to finish it on the web portal. |
| 3 | **Editing a saved payment method** | `/api/user/updatePaymentMethod`, `/api/user/editPaymentMethod` → **404** | Edit is implemented as add-then-delete (`PaymentMethodsRepository.replacePaymentMethod`). The new entry is created **first**, so a failure leaves the original intact. The user is told up front that saving replaces the method. If the delete half fails, the app says so rather than silently leaving two entries. |
| 4 | **Transaction-history pagination** | `/api/accountsTransactions/all` exists (**401**) but its paging parameters are not documented and could not be confirmed with a session | The history is fetched unpaginated, exactly as before. No `limit`/`skip`/`page` parameters were guessed. Filtering by type (`where.type`) is used because it is the shape the existing code and the other list endpoints share. |
| 5 | **Balance correction for clients** | `balance-correction` appears as a transaction **type** in the history; whether a client may *create* one could not be determined without an authenticated session | Not exposed as a client action. It remains a read-only history filter and renders correctly when the backend returns one. This is the conservative reading of the requirement. |
| 6 | **MyFatoorah quote response shape** | `/api/accountsTransactions/myfatoorah-quote` exists (**401**, requires the `client` permission) | The request is exactly `{accountId, amount}` as documented. The response is parsed defensively (`amount` / `fee` / `total` / `currency` / `feeType` / `feeValue`, including a nested `quote`/`doc`/`data` wrapper) and the full body is retained. **Fees are never computed in the app** — any value the backend does not return is simply not displayed. |
| 7 | **MyFatoorah redirect URL key** | Returned inside the `/accountsTransactions/add` response; the exact key is the gateway's own | Searched case-insensitively for `paymentUrl` / `invoiceUrl` / `redirectUrl` / `url`, and only accepted when it is a valid `http(s)` URL. If none is returned the app shows the created transaction's real status instead of claiming a redirect. |
| 8 | **MT5 fields on an account** | `/api/accounts/all` exists (**401**); the MT5 block's exact field names could not be confirmed | `AccountModel` reads MT5 login / server / group from either a nested `mt5` object or flattened keys, and `hasMt5Details` is `false` when nothing was returned, so the UI hides the section rather than showing blanks. Trading passwords are deliberately **not** read, displayed or logged. |
| 9 | **Two-factor authentication** | No endpoint found | The "Account Security — 2FA Enabled, Last changed 12d ago" tile was removed. It stated something untrue and its tap handler did nothing. |
| 10 | **Notification / location / e-mail / SMS preferences** | No endpoints found | Those four switches in App Settings were local-only no-ops and were removed. Push Notifications remains and reflects the real OS permission plus real backend device registration. |
| 11 | **Count of signed agreements** | `/api/agreements/all` exists (**401**) but the profile tile needs a count before the list is opened | The fabricated "4 Active contracts signed" subtitle was replaced with a static description. The real list and statuses are shown on the Agreements screen itself. |
| 12 | **Reply count on a help-desk ticket list item** | `/api/tickets/all` does not always embed `replyList` | The badge is drawn only when `replyList` is present; the previous `isReplied ? 1 : 0` stand-in was removed. |

## Firebase

`POST /api/notifications/device/register` works and is called after sign-in,
but the backend only *delivers* FCM messages once its own Firebase Admin
service credentials are configured. Registering a device token from the app is
necessary but not sufficient.

The app's own Firebase config files (`android/app/google-services.json`,
`ios/Runner/GoogleService-Info.plist`) are not in the repository. The build and
the app work without them; push stays inactive until they are added. See the
README for the steps.

## Web portal

The Boker Web project was not available while this work was done
(`https://boker.egytag.com` returns `502`, and the portal's own JavaScript
under `atm-crm.egytag.com` is behind authentication). Contracts were therefore
taken from the written specification and confirmed endpoint-by-endpoint against
the live API. Where a response body could not be observed, it is parsed
defensively and missing values are hidden rather than filled in — the cases are
listed above.
