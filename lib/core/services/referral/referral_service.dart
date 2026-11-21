import 'dart:developer' as dev;

import '../../config/local/cache_service.dart';

/// Affiliate referral parameters carried by an invitation link.
///
/// Invitation links look like:
/// `https://<portal-domain>/login?ref=6aec150192786050a0a5acc9&accGroupId=6`
class ReferralData {
  /// IB referral id (`ref`), sent to the backend as `$ref`.
  final String? ref;

  /// Account group id (`accGroupId`), sent to the backend as `$accGroupId`.
  final String? accGroupId;

  const ReferralData({this.ref, this.accGroupId});

  static const ReferralData empty = ReferralData();

  bool get isEmpty => ref == null && accGroupId == null;

  bool get isNotEmpty => !isEmpty;

  @override
  bool operator ==(Object other) =>
      other is ReferralData &&
      other.ref == ref &&
      other.accGroupId == accGroupId;

  @override
  int get hashCode => Object.hash(ref, accGroupId);

  @override
  String toString() => 'ReferralData(ref: $ref, accGroupId: $accGroupId)';
}

/// Captures and persists affiliate referral parameters.
///
/// Lifecycle:
///  1. an invitation link is opened (cold or warm start);
///  2. [captureFromUri] extracts `ref` / `accGroupId` and persists them;
///  3. the user may navigate freely, or close and reopen the app;
///  4. registration reads [current] and sends the values;
///  5. [clear] runs **only** after the account was created successfully.
///
/// Storage reuses the app's existing [CacheService] (SharedPreferences)
/// wrapper — no second storage mechanism is introduced. The values are also
/// held in memory so the registration payload can be built synchronously.
class ReferralService {
  ReferralService._();

  static final ReferralService instance = ReferralService._();

  /// Query parameter names on the invitation link.
  static const String refParamName = 'ref';
  static const String accGroupIdParamName = 'accGroupId';

  static const String _refKey = 'affiliate_ref';
  static const String _accGroupIdKey = 'affiliate_acc_group_id';

  ReferralData _current = ReferralData.empty;
  bool _restored = false;

  /// Signature of the last link that was processed, so the same link arriving
  /// twice (e.g. a redirect chain, or a re-delivered intent) is not handled
  /// repeatedly.
  String? _lastProcessedSignature;

  /// The referral parameters currently held, if any.
  ReferralData get current => _current;

  bool get hasReferral => _current.isNotEmpty;

  /// Loads the persisted values into memory. Call once during start-up,
  /// before the first screen is built.
  Future<void> restore() async {
    if (_restored) return;
    _restored = true;
    try {
      final ref = await CacheService.getData<String>(_refKey);
      final accGroupId = await CacheService.getData<String>(_accGroupIdKey);
      _current = ReferralData(
        ref: _normalise(ref),
        accGroupId: _normalise(accGroupId),
      );
    } catch (_) {
      // A storage failure must never block app start-up.
      _current = ReferralData.empty;
    }
  }

  /// Extracts `ref` / `accGroupId` from [uri] and persists whatever is found.
  ///
  /// This is deliberately domain-agnostic: the host is never inspected, so any
  /// portal domain works without a code change. (The *operating system* still
  /// needs each domain declared for App Links / Universal Links — see
  /// docs/BACKEND_GAPS.md.)
  ///
  /// Returns `true` when the stored values changed.
  bool captureFromUri(Uri uri) {
    final ref = _normalise(uri.queryParameters[refParamName]);
    final accGroupId = _normalise(uri.queryParameters[accGroupIdParamName]);

    // Nothing referral-related on this URI: leave what is stored alone.
    if (ref == null && accGroupId == null) return false;

    final signature = '$ref|$accGroupId';
    if (signature == _lastProcessedSignature) return false;
    _lastProcessedSignature = signature;

    return _apply(ReferralData(ref: ref, accGroupId: accGroupId));
  }

  /// Applies a new set of referral values.
  ///
  /// Replacement policy:
  ///  * a new link replaces the previous values;
  ///  * a parameter that is absent/empty on the new link never overwrites a
  ///    stored value — a partial link keeps the missing half.
  bool _apply(ReferralData incoming) {
    final merged = ReferralData(
      ref: incoming.ref ?? _current.ref,
      accGroupId: incoming.accGroupId ?? _current.accGroupId,
    );

    if (merged == _current) return false;

    _current = merged;
    _restored = true;
    _persist(merged);
    return true;
  }

  /// Clears the referral values.
  ///
  /// Called **only** after an account has been created successfully. It is
  /// never called when registration fails, and never on screen init.
  Future<void> clear() async {
    _current = ReferralData.empty;
    _restored = true;
    _lastProcessedSignature = null;
    try {
      await Future.wait([
        CacheService.remove(_refKey),
        CacheService.remove(_accGroupIdKey),
      ]);
    } catch (e) {
      dev.log('Failed to clear referral data: $e', name: 'REFERRAL');
    }
  }

  /// Adds `$ref` / `$accGroupId` to a registration payload.
  ///
  /// [overrideRef] / [overrideAccGroupId] let the caller pass values it
  /// already has (e.g. straight off the current route); they win over the
  /// stored ones. Keys are omitted entirely when there is no value, so an
  /// ordinary registration is byte-for-byte unchanged.
  void applyToRegistrationPayload(
    Map<String, dynamic> payload, {
    String? overrideRef,
    String? overrideAccGroupId,
  }) {
    final ref = _normalise(overrideRef) ?? _current.ref;
    final accGroupId = _normalise(overrideAccGroupId) ?? _current.accGroupId;

    if (ref != null) {
      payload[r'$ref'] = ref;
    }
    if (accGroupId != null) {
      // The backend stores the account group as a number when it is one.
      payload[r'$accGroupId'] = int.tryParse(accGroupId) ?? accGroupId;
    }
  }

  void _persist(ReferralData data) {
    // Fire-and-forget: the in-memory value is already authoritative for this
    // session, persistence only has to survive a restart.
    Future.wait([
      if (data.ref != null)
        CacheService.saveData(_refKey, data.ref!)
      else
        CacheService.remove(_refKey),
      if (data.accGroupId != null)
        CacheService.saveData(_accGroupIdKey, data.accGroupId!)
      else
        CacheService.remove(_accGroupIdKey),
    ]).catchError((Object e) {
      dev.log('Failed to persist referral data: $e', name: 'REFERRAL');
      return <Object>[];
    });
  }

  static String? _normalise(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  /// Test seam: sets the in-memory state without touching storage.
  void debugSet(ReferralData data) {
    _current = data;
    _restored = true;
    _lastProcessedSignature = null;
  }

  /// Test seam: forgets the de-duplication marker.
  void debugResetDeduplication() => _lastProcessedSignature = null;
}
