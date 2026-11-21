import 'package:boker/core/services/referral/referral_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds the registration payload the way SignUpPage does, so the tests
/// assert on what actually reaches `/user/register`.
Map<String, dynamic> buildRegistrationPayload({
  String? routeRef,
  String? routeAccGroupId,
}) {
  final data = <String, dynamic>{
    'clientType': 'customer',
    'email': 'client@example.com',
    'password': 'Str0ng!Pass',
    'confirmPassword': 'Str0ng!Pass',
    'mobile': '500000000',
    'phonePrefix': '+966',
    'termsAgreed': true,
    'promoCode': '',
    'isIb': false,
  };

  ReferralService.instance.applyToRegistrationPayload(
    data,
    overrideRef: routeRef,
    overrideAccGroupId: routeAccGroupId,
  );
  return data;
}

void main() {
  const invitationRef = '6aec150192786050a0a5acc9';

  late ReferralService service;

  setUp(() async {
    // A real (in-memory) SharedPreferences, so persistence is exercised
    // rather than mocked away.
    SharedPreferences.setMockInitialValues({});
    service = ReferralService.instance;
    await service.clear();
    service.debugResetDeduplication();
  });

  group('capturing an affiliate link', () {
    test('extracts ref and accGroupId from a /login invitation', () {
      final changed = service.captureFromUri(
        Uri.parse(
          'https://any-domain.com/login?ref=$invitationRef&accGroupId=6',
        ),
      );

      expect(changed, isTrue);
      expect(service.current.ref, invitationRef);
      expect(service.current.accGroupId, '6');
    });

    test('works for any domain - the host is never inspected', () {
      service.captureFromUri(
        Uri.parse('https://boker.egytag.com/login?ref=a1&accGroupId=2'),
      );
      expect(service.current.ref, 'a1');

      service.captureFromUri(
        Uri.parse('https://partner.example.org/login?ref=b2&accGroupId=3'),
      );
      expect(service.current.ref, 'b2');
      expect(service.current.accGroupId, '3');
    });

    test('ignores other query parameters on the link', () {
      service.captureFromUri(
        Uri.parse(
          'https://any-domain.com/login'
          '?ref=$invitationRef&accGroupId=6&utm_source=mail&callback=/home',
        ),
      );

      expect(service.current.ref, invitationRef);
      expect(service.current.accGroupId, '6');
    });

    test('a link with no referral parameters changes nothing', () {
      service.captureFromUri(
        Uri.parse('https://any-domain.com/login?ref=$invitationRef'),
      );

      final changed = service.captureFromUri(
        Uri.parse('https://any-domain.com/home'),
      );

      expect(changed, isFalse);
      expect(service.current.ref, invitationRef);
    });

    test('empty parameters never wipe stored values', () {
      service.captureFromUri(
        Uri.parse(
          'https://any-domain.com/login?ref=$invitationRef&accGroupId=6',
        ),
      );

      service.captureFromUri(
        Uri.parse('https://any-domain.com/login?ref=&accGroupId='),
      );

      expect(service.current.ref, invitationRef);
      expect(service.current.accGroupId, '6');
    });

    test('the same link arriving twice is processed once', () {
      final uri = Uri.parse(
        'https://any-domain.com/login?ref=$invitationRef&accGroupId=6',
      );

      expect(service.captureFromUri(uri), isTrue);
      expect(service.captureFromUri(uri), isFalse);
      expect(service.current.ref, invitationRef);
    });
  });

  group('replacement policy for a new link', () {
    test('a new complete link replaces both values', () {
      service.captureFromUri(
        Uri.parse('https://any-domain.com/login?ref=old&accGroupId=1'),
      );

      service.captureFromUri(
        Uri.parse('https://any-domain.com/login?ref=new&accGroupId=9'),
      );

      expect(service.current.ref, 'new');
      expect(service.current.accGroupId, '9');
    });

    test('a link with only ref keeps the stored accGroupId', () {
      service.captureFromUri(
        Uri.parse('https://any-domain.com/login?ref=old&accGroupId=1'),
      );

      service.captureFromUri(Uri.parse('https://any-domain.com/login?ref=new'));

      expect(service.current.ref, 'new');
      expect(service.current.accGroupId, '1');
    });

    test('a link with only accGroupId keeps the stored ref', () {
      service.captureFromUri(
        Uri.parse('https://any-domain.com/login?ref=old&accGroupId=1'),
      );

      service.captureFromUri(
        Uri.parse('https://any-domain.com/login?accGroupId=9'),
      );

      expect(service.current.ref, 'old');
      expect(service.current.accGroupId, '9');
    });

    test('a partial link is captured when nothing is stored yet', () {
      service.captureFromUri(
        Uri.parse('https://any-domain.com/login?accGroupId=6'),
      );

      expect(service.current.ref, isNull);
      expect(service.current.accGroupId, '6');
      expect(service.hasReferral, isTrue);
    });
  });

  group('persistence across restarts', () {
    test('values survive closing and reopening the app', () async {
      service.captureFromUri(
        Uri.parse(
          'https://any-domain.com/login?ref=$invitationRef&accGroupId=6',
        ),
      );
      // Let the fire-and-forget write land.
      await Future<void>.delayed(Duration.zero);

      // Simulate a force-stop + relaunch: memory is gone, storage is not.
      service.debugSet(ReferralData.empty);
      await _forceRestore(service);

      expect(service.current.ref, invitationRef);
      expect(service.current.accGroupId, '6');
    });

    test('a cleared referral does not come back after a restart', () async {
      service.captureFromUri(
        Uri.parse('https://any-domain.com/login?ref=$invitationRef'),
      );
      await Future<void>.delayed(Duration.zero);

      await service.clear();

      service.debugSet(ReferralData.empty);
      await _forceRestore(service);

      expect(service.current.isEmpty, isTrue);
    });
  });

  group('registration payload', () {
    test(r'includes $ref and $accGroupId from a link opened earlier', () {
      service.captureFromUri(
        Uri.parse(
          'https://any-domain.com/login?ref=$invitationRef&accGroupId=6',
        ),
      );

      final payload = buildRegistrationPayload();

      expect(payload[r'$ref'], invitationRef);
      // Numeric account groups are sent as numbers.
      expect(payload[r'$accGroupId'], 6);
      // Existing fields are untouched.
      expect(payload['email'], 'client@example.com');
      expect(payload['clientType'], 'customer');
    });

    test('keeps a non-numeric accGroupId as a string', () {
      service.captureFromUri(
        Uri.parse('https://any-domain.com/login?accGroupId=group-a'),
      );

      expect(buildRegistrationPayload()[r'$accGroupId'], 'group-a');
    });

    test('route parameters win over the stored ones', () {
      service.captureFromUri(
        Uri.parse('https://any-domain.com/login?ref=stored&accGroupId=1'),
      );

      final payload = buildRegistrationPayload(
        routeRef: 'from-route',
        routeAccGroupId: '9',
      );

      expect(payload[r'$ref'], 'from-route');
      expect(payload[r'$accGroupId'], 9);
    });

    test('sends only the half that is known', () {
      service.captureFromUri(
        Uri.parse('https://any-domain.com/login?ref=$invitationRef'),
      );

      final payload = buildRegistrationPayload();

      expect(payload[r'$ref'], invitationRef);
      expect(payload.containsKey(r'$accGroupId'), isFalse);
    });

    test('adds nothing at all when there is no referral', () {
      final payload = buildRegistrationPayload();

      expect(payload.containsKey(r'$ref'), isFalse);
      expect(payload.containsKey(r'$accGroupId'), isFalse);
    });
  });

  group('referral lifecycle', () {
    test('a failed registration keeps the referral for the next try', () {
      service.captureFromUri(
        Uri.parse(
          'https://any-domain.com/login?ref=$invitationRef&accGroupId=6',
        ),
      );

      // Registration failed: nothing clears the referral, so the retry still
      // carries it.
      expect(service.hasReferral, isTrue);
      expect(buildRegistrationPayload()[r'$ref'], invitationRef);
    });

    test('a successful registration clears it', () async {
      service.captureFromUri(
        Uri.parse(
          'https://any-domain.com/login?ref=$invitationRef&accGroupId=6',
        ),
      );

      await service.clear();

      expect(service.hasReferral, isFalse);
      final payload = buildRegistrationPayload();
      expect(payload.containsKey(r'$ref'), isFalse);
      expect(payload.containsKey(r'$accGroupId'), isFalse);
    });

    test(
      'opening the app with no link after registering sends no stale values',
      () async {
        service.captureFromUri(
          Uri.parse(
            'https://any-domain.com/login?ref=$invitationRef&accGroupId=6',
          ),
        );
        await service.clear(); // successful registration

        // Fresh launch, no invitation link.
        service.debugSet(ReferralData.empty);
        await _forceRestore(service);
        service.captureFromUri(Uri.parse('https://any-domain.com/sign-up'));

        final payload = buildRegistrationPayload();
        expect(payload.containsKey(r'$ref'), isFalse);
        expect(payload.containsKey(r'$accGroupId'), isFalse);
      },
    );

    test('navigating between screens does not lose the referral', () {
      service.captureFromUri(
        Uri.parse(
          'https://any-domain.com/login?ref=$invitationRef&accGroupId=6',
        ),
      );

      // Every in-app navigation runs through the same capture call.
      for (final path in [
        '/sign-up',
        '/sign-in',
        '/forgot-password',
        '/home',
      ]) {
        service.captureFromUri(Uri.parse('https://any-domain.com$path'));
      }

      expect(service.current.ref, invitationRef);
      expect(service.current.accGroupId, '6');
    });
  });

  group('ReferralData', () {
    test('reports emptiness correctly', () {
      expect(ReferralData.empty.isEmpty, isTrue);
      expect(const ReferralData(ref: 'a').isNotEmpty, isTrue);
      expect(const ReferralData(accGroupId: '1').isNotEmpty, isTrue);
    });
  });
}

/// `restore()` is guarded against running twice; tests need it to re-read
/// storage as a fresh launch would.
Future<void> _forceRestore(ReferralService service) async {
  final prefs = await SharedPreferences.getInstance();
  final ref = prefs.getString('affiliate_ref');
  final accGroupId = prefs.getString('affiliate_acc_group_id');
  service.debugSet(ReferralData(ref: ref, accGroupId: accGroupId));
}
