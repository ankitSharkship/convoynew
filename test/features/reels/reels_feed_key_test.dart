import 'package:convoynew/features/reels/domain/entities/reels_feed_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('equal keys are equal and share a hash (so they share one loaded feed)', () {
    const a = ReelsFeedKey(categoryId: 'c1', areaCell: '8642c084fffffff');
    const b = ReelsFeedKey(categoryId: 'c1', areaCell: '8642c084fffffff');
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect({a: 1}[b], 1);
  });

  test('any difference makes it a different feed', () {
    const base = ReelsFeedKey(categoryId: 'c1', areaCell: 'cell');
    expect(base, isNot(const ReelsFeedKey(categoryId: 'c2', areaCell: 'cell')));
    expect(base, isNot(const ReelsFeedKey(categoryId: 'c1', areaCell: 'other')));
    expect(base, isNot(const ReelsFeedKey(categoryId: 'c1')));
    expect(const ReelsFeedKey(), isNot(const ReelsFeedKey(areaCell: 'cell')));
  });

  test('the empty key is the plain, newest-first feed', () {
    const key = ReelsFeedKey();
    expect(key.hasArea, isFalse);
    expect(key.sort, ReelsSort.latest);
    expect(key, const ReelsFeedKey(categoryId: null, areaCell: null));
  });

  test('an area feed is ranked by popularity, a category alone is not', () {
    expect(const ReelsFeedKey(areaCell: 'cell').sort, ReelsSort.popular);
    expect(const ReelsFeedKey(areaCell: 'cell').hasArea, isTrue);
    expect(const ReelsFeedKey(categoryId: 'c1', areaCell: 'cell').sort, ReelsSort.popular);
    expect(const ReelsFeedKey(categoryId: 'c1').sort, ReelsSort.latest);
  });

  test('sort values match the API', () {
    expect(ReelsSort.latest.apiValue, 'latest');
    expect(ReelsSort.popular.apiValue, 'popular');
  });
}
