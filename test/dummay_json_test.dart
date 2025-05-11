import 'package:google_books/google_books.dart';
import 'package:test/test.dart';

import 'test_json.dart';

void main() {
  group('GBook Model JSON Parsing', () {
    final items = (googleResponse['items'] as List<dynamic>);

    test('Parses all GBooks from googleResponse', () {
      final gBooks = items.map((item) => Book.fromJson(item)).toList();
      expect(gBooks.length, items.length);
    });

    test('GBook fields are parsed correctly', () {
      final book = Book.fromJson(items[0]);
      expect(book.id, isNotEmpty);
      expect(book.etag, isNotNull);
      expect(book.info.title, isNotEmpty);
      expect(book.info.authors, isA<List<String>>());
      expect(book.info.publisher, isNotNull);
      expect(book.info.industryIdentifiers, isA<List<IndustryIdentifier>>());
      expect(book.saleInfo.country, isNotEmpty);
      expect(book.saleInfo.saleability, isNotEmpty);
      expect(book.saleInfo.isEbook, isA<bool>());
    });

    test('Handles optional and missing fields gracefully', () {
      final book = Book.fromJson(items[2]); // This one has missing fields
      expect(book.info.subtitle, anyOf(isNull, isA<String>()));
      expect(book.info.averageRating, anyOf(isNull, isA<num>()));
      expect(book.saleInfo.listPrice, anyOf(isNull, isA<SaleInfoListPrice>()));
    });

    test('GBookInfo imageLinks are parsed as Map<String, Uri>', () {
      final book = Book.fromJson(items[0]);
      expect(book.info.imageLinks, isA<Map<String, Uri>>());
      expect(book.info.imageLinks.values.first, isA<Uri>());
    });

    test('IndustryIdentifiers are parsed correctly', () {
      final book = Book.fromJson(items[0]);
      expect(book.info.industryIdentifiers, isA<List<IndustryIdentifier>>());
      expect(book.info.industryIdentifiers.first.type, isNotEmpty);
      expect(book.info.industryIdentifiers.first.identifier, isNotEmpty);
    });

    test('SaleInfo offers and prices are parsed if present', () {
      final book = Book.fromJson(items[1]);
      expect(book.saleInfo.listPrice, isA<SaleInfoListPrice>());
      expect(book.saleInfo.retailPrice, isA<SaleInfoListPrice>());
      expect(book.saleInfo.offers, isA<List<Offer>>());
      expect(book.saleInfo.offers!.first.listPrice, isA<OfferListPrice>());
    });

    test('GBook toString returns expected format', () {
      final book = Book.fromJson(items[0]);
      expect(book.toString(), contains(book.id));
      expect(book.toString(), contains(book.info.title));
    });
  });
}
