import 'package:flutter_test/flutter_test.dart';

import 'package:decide/features/users/presentation/widgets/user_avatar.dart';

void main() {
  test('uses two initials from a full display name', () {
    expect(initialsFor(displayName: 'Eduardo Garcia', username: 'rusito'), 'EG');
  });

  test('falls back to the username when there is no display name', () {
    expect(initialsFor(displayName: '', username: 'rusito'), 'RU');
  });

  test('uses one letter for a single short word', () {
    expect(initialsFor(displayName: '', username: 'a'), 'A');
  });

  test('returns a placeholder when both are empty', () {
    expect(initialsFor(displayName: '', username: ''), '?');
  });
}
