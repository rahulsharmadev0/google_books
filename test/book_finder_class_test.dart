import 'package:google_books/google_books.dart';
import 'package:google_books/src/google_books.dart';
import 'package:test/test.dart';

void main() {
  group('BookFinder', () {
    late GoogleBooks bookFinder;

    setUp(() {
      bookFinder = GoogleBooks();
    });

    tearDown(() {
      bookFinder.dispose();
    });

    // Integration test - requires network connection
    test('queryBooks returns books for valid queries', () async {
      final books = await bookFinder.queryBooks(
        'REST API Design',
        maxResults: 3,
        printType: PrintType.books,
        orderBy: OrderBy.relevance,
      );

      expect(books, isA<List<Book>>());
      expect(books, isNotEmpty);
      expect(books.first.id, isNotEmpty);
    }, timeout: Timeout(Duration(seconds: 30)));

    // Integration test - requires network connection
    test('getBookById returns a specific book', () async {
      const String knownBookId = '4lZcsRwXo6MC'; // REST API Design Rulebook

      final book = await bookFinder.getBookById(knownBookId);

      expect(book, isA<Book>());
      expect(book.id, knownBookId);
      expect(book.info.title, contains('REST API'));
    }, timeout: Timeout(Duration(seconds: 30)));

    // Test validation
    test('queryBooks throws error for empty query', () async {
      expect(
        () => bookFinder.queryBooks(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    // Test validation
    test('getBookById throws error for empty ID', () async {
      expect(
        () => bookFinder.getBookById(''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
