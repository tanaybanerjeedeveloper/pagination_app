import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/home_page.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late HomePageState sut;

  setUp(() {
    sut = HomePageState();
  });

  test("initial values are correct", () {
    expect(sut.filteredPosts, []);
    expect(sut.searchedValue, '');
  });
}
