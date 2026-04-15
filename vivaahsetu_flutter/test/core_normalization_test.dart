import 'package:flutter_test/flutter_test.dart';
import 'package:vivaahsetu_flutter/core/models.dart';
import 'package:vivaahsetu_flutter/core/normalization.dart' as adapter;

void main() {
  test('normalizeMatchFilters supports snake_case and camelCase keys', () {
    final filters = adapter.normalizeMatchFilters({
      'minAge': 24,
      'maxAge': 30,
      'city': 'Pune',
      'occupation': 'Engineer',
    });

    expect(filters['age_min'], 24);
    expect(filters['minAge'], 24);
    expect(filters['age_max'], 30);
    expect(filters['maxAge'], 30);
    expect(filters['location'], 'Pune');
    expect(filters['city'], 'Pune');
    expect(filters['profession'], 'Engineer');
    expect(filters['occupation'], 'Engineer');
  });

  test('normalizeUserPayload maps backend aliases', () {
    final normalized = adapter.normalizeUserPayload({
      '_id': 'abc123',
      'date_of_birth': '1997-05-01',
      'location': 'Bengaluru, Karnataka',
      'profession': 'Designer',
      'request_sent': true,
    });

    expect(normalized['id'], 'abc123');
    expect(normalized['dob'], '1997-05-01');
    expect(normalized['dateOfBirth'], '1997-05-01');
    expect(normalized['city'], 'Bengaluru');
    expect(normalized['occupation'], 'Designer');
    expect(normalized['requestSent'], true);
  });

  test('Plan model normalizes availability aliases', () {
    final plan = Plan.fromMap({
      'id': 'focus',
      'name': 'Focus',
      'original_price': 699,
      'discounted_price': 210,
      'is_available_for_checkout': true,
      'features': ['Chat', 'Contacts'],
    });

    expect(plan.id, 'focus');
    expect(plan.price, 699);
    expect(plan.discountedPrice, 210);
    expect(plan.available, true);
    expect(plan.features.length, 2);
  });

  test('ChatMessage model supports snake_case payload', () {
    final message = ChatMessage.fromMap({
      'id': 'm1',
      'sender_id': 'u1',
      'receiver_id': 'u2',
      'content': 'Hello',
      'created_at': '2026-04-14T06:00:00Z',
      'read': false,
      'status': 'failed',
    });

    expect(message.id, 'm1');
    expect(message.senderId, 'u1');
    expect(message.receiverId, 'u2');
    expect(message.status, ChatMessageStatus.failed);
  });
}
