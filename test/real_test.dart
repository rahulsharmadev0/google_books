import 'package:google_books/google_books.dart';
import 'package:test/test.dart';

void main() {
  group('Google Books API Integration', () {
    late GoogleBooks bookFinder;
    setUp(() {
      bookFinder = GoogleBooks();
    });
    test('queryBooks returns results for a real query', () async {
      final books = await bookFinder.queryBooks('Alchemist', maxResults: 20);
      expect(books.length, 20);
    });

    test('getSpecificBook returns a valid book', () async {
      // Use a known book ID from the test_json.dart sample
      final book = await bookFinder.getBookById('4lZcsRwXo6MC');
      expect(book.id, '4lZcsRwXo6MC');
      expect(book.info.title, contains('REST API'));
    });
  });
}
