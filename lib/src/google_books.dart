// Copyright 2020 Bruno D'Luka

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model/gbook.dart';

/// A class to interact with the Google Books API
///
/// Use this class to search for books and retrieve book details
/// in a structured and reusable way.
class GoogleBooks {
  /// Base URL for the Google Books API
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  /// HTTP client for making API requests
  final http.Client _client;

  /// API key for the Google Books API
  final String? _apiKey;

  /// Whether to rescheme image links to HTTPS
  final bool _reschemeImageLinks;

  /// Creates a new [GoogleBooks] instance
  ///
  /// Optional parameters:
  /// - [client]: Custom HTTP client for testing and DI
  /// - [apiKey]: Your Google Books API key
  /// - [reschemeImageLinks]: Whether to convert image URLs to HTTPS
  GoogleBooks({
    http.Client? client,
    String? apiKey,
    bool reschemeImageLinks = false,
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey,
        _reschemeImageLinks = reschemeImageLinks;

  /// Disposes resources used by this instance
  void dispose() {
    _client.close();
  }

  /// Query books from the Google Books API
  ///
  /// Required:
  /// - [query]: The search query string. Cannot be empty.
  ///
  /// Optional parameters:
  /// - [queryType]: Type of query (title, author, etc.). Restricts search to a specific field.
  /// - [langRestrict]: Restricts results to a specific language (Two-letter ISO-639-1 code).
  /// - [maxResults]: Maximum number of results to return (max allowable: 40).
  /// - [startIndex]: Starting index for pagination (0-based).
  /// - [orderBy]: Order results by newest or relevance (default).
  /// - [printType]: Filter by books, magazines or both.
  /// - [filter]: Filter by availability or content view type.
  /// - [projection]: Level of detail to include in the results.
  /// - [download]: Restrict to volumes with a specific download format.
  Future<List<Book>> queryBooks(
    String query, {
    QueryType? queryType,
    String? langRestrict,
    int maxResults = 10,
    int startIndex = 0,
    OrderBy? orderBy,
    PrintType? printType = PrintType.all,
    Filter? filter,
    Projection? projection,
    DownloadFormat? download,
  }) async {
    if (query.isEmpty) {
      throw ArgumentError('Query cannot be empty');
    }

    // Google Books API has a maximum limit of 40 results
    if (maxResults > 40) {
      maxResults = 40;
    }

    try {
      final uri = _buildQueryUri(
        query,
        queryType: queryType,
        langRestrict: langRestrict,
        maxResults: maxResults,
        orderBy: orderBy,
        printType: printType,
        startIndex: startIndex,
        filter: filter,
        projection: projection,
        download: download,
      );

      final response = await _client.get(uri);
      return _processQueryResponse(response);
    } catch (e) {
      // Wrap raw exceptions with more context
      throw BookFinderException('Failed to query books: ${e.toString()}', e);
    }
  }

  /// Get a specific book by its ID
  ///
  /// Required:
  /// - [id]: The Google Books volume ID
  Future<Book> getBookById(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Book ID cannot be empty');
    }

    try {
      final uri = _buildBookByIdUri(id);
      final response = await _client.get(uri);
      return _processBookResponse(response);
    } catch (e) {
      throw BookFinderException('Failed to get book by ID: ${e.toString()}', e);
    }
  }

  /// Builds a URI for querying books
  Uri _buildQueryUri(
    String query, {
    QueryType? queryType,
    String? langRestrict,
    int maxResults = 10,
    int startIndex = 0,
    OrderBy? orderBy,
    PrintType? printType = PrintType.all,
    Filter? filter,
    Projection? projection,
    DownloadFormat? download,
  }) {
    final queryParams = <String, String>{
      'q': queryType != null
          ? '${queryType.name}:${query.trim().replaceAll(' ', '+')}'
          : query.trim().replaceAll(' ', '+'),
      'maxResults': maxResults.toString(),
      'startIndex': startIndex.toString(),
    };

    if (_apiKey != null) {
      queryParams['key'] = _apiKey!;
    }

    if (langRestrict != null) {
      queryParams['langRestrict'] = langRestrict;
    }

    if (orderBy != null) {
      queryParams['orderBy'] = orderBy.toString().split('.').last;
    }

    if (printType != null) {
      queryParams['printType'] = printType.toString().split('.').last;
    }

    // Add new filter parameter
    if (filter != null) {
      // Convert enum value to the format the API expects
      final filterName = filter.toString().split('.').last;
      // Convert camelCase to kebab-case for certain filters
      final apiFilterName = filterName == 'freeEbooks'
          ? 'free-ebooks'
          : filterName == 'paidEbooks'
              ? 'paid-ebooks'
              : filterName;
      queryParams['filter'] = apiFilterName;
    }

    // Add projection parameter
    if (projection != null) {
      queryParams['projection'] = projection.toString().split('.').last;
    }

    // Add download format parameter
    if (download != null) {
      queryParams['download'] = download.toString().split('.').last;
    }

    return Uri.parse(_baseUrl).replace(queryParameters: queryParams);
  }

  /// Builds a URI for getting a specific book by ID
  Uri _buildBookByIdUri(String id) {
    final queryParams = <String, String>{};

    if (_apiKey != null) {
      queryParams['key'] = _apiKey!;
    }

    return Uri.parse('$_baseUrl/${id.trim()}').replace(queryParameters: queryParams);
  }

  /// Process the query response from the API
  List<Book> _processQueryResponse(http.Response response) {
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic>? items = jsonData['items'] as List<dynamic>?;

      if (items == null || items.isEmpty) {
        return [];
      }

      return items
          .map((item) => Book.fromJson(
                item,
                reschemeImageLinks: _reschemeImageLinks,
              ))
          .toList();
    } else {
      _handleErrorResponse(response);
      return []; // This line won't be reached due to the exception thrown above
    }
  }

  /// Process the book response from the API
  Book _processBookResponse(http.Response response) {
    if (response.statusCode == 200) {
      return Book.fromJson(
        jsonDecode(response.body),
        reschemeImageLinks: _reschemeImageLinks,
      );
    } else {
      _handleErrorResponse(response);
      throw StateError("Unreachable code"); // This line won't be reached
    }
  }

  /// Handle error responses from the API
  void _handleErrorResponse(http.Response response) {
    switch (response.statusCode) {
      case 400:
        throw BadRequestException('Invalid request: ${response.body}');
      case 401:
        throw AuthenticationException('Authentication failed: ${response.body}');
      case 403:
        throw AuthorizationException('Not authorized: ${response.body}');
      case 404:
        throw NotFoundException('Resource not found: ${response.body}');
      case 429:
        throw RateLimitException('Rate limit exceeded: ${response.body}');
      case 500:
      case 502:
      case 503:
      case 504:
        throw ServerException('Server error: ${response.body}');
      default:
        throw BookFinderException(
          'Unexpected error (${response.statusCode}): ${response.body}',
        );
    }
  }
}

/// Base exception class for BookFinder
class BookFinderException implements Exception {
  final String message;
  final Object? cause;

  BookFinderException(this.message, [this.cause]);

  @override
  String toString() =>
      'BookFinderException: $message${cause != null ? ', Cause: $cause' : ''}';
}

/// Exception thrown when the request is malformed
class BadRequestException extends BookFinderException {
  BadRequestException(String message) : super(message);
}

/// Exception thrown when authentication fails
class AuthenticationException extends BookFinderException {
  AuthenticationException(String message) : super(message);
}

/// Exception thrown when the request is not authorized
class AuthorizationException extends BookFinderException {
  AuthorizationException(String message) : super(message);
}

/// Exception thrown when the requested resource is not found
class NotFoundException extends BookFinderException {
  NotFoundException(String message) : super(message);
}

/// Exception thrown when the rate limit is exceeded
class RateLimitException extends BookFinderException {
  RateLimitException(String message) : super(message);
}

/// Exception thrown when the server returns an error
class ServerException extends BookFinderException {
  ServerException(String message) : super(message);
}

// Re-export enums from books_finder_base.dart for compatibility

/// Special keywords you can specify in the search terms to search by particular fields
enum QueryType {
  /// Returns results where the text following this keyword is found in the title.
  intitle,

  /// Returns results where the text following this keyword is found in the author.
  inauthor,

  /// Returns results where the text following this keyword is found in the publisher.
  inpublisher,

  /// Returns results where the text following this keyword is listed in the category list of the volume.
  subject,

  /// Returns results where the text following this keyword is the ISBN number.
  isbn,

  /// Returns results where the text following this keyword is the Library of Congress Control Number.
  lccn,

  /// Returns results where the text following this keyword is the Online Computer Library Center number.
  oclc,
}

/// Order the query by `newest` or `relevance`
enum OrderBy {
  /// Returns search results in order of the newest published date
  /// to the oldest.
  newest,

  /// Returns search results in order of the most relevant to least
  /// (this is the default).
  relevance,
}

/// Type of print material to filter by
enum PrintType {
  /// Return all volume content types (no restriction). This is the default.
  all,

  /// Return only books.
  books,

  /// Return only magazines.
  magazines,
}

/// Filter search results by volume type and availability
enum Filter {
  /// Restrict results to volumes where at least part of the text is previewable
  partial,

  /// Restrict results to volumes where all of the text is viewable
  full,

  /// Restrict results to free Google eBooks
  freeEbooks,

  /// Restrict results to Google eBooks with a price
  paidEbooks,

  /// Restrict results to Google eBooks, paid or free
  ebooks,
}

/// Specifies a predefined set of Volume fields to return
enum Projection {
  /// Returns all Volume fields
  full,

  /// Returns a subset of Volume fields
  lite,
}

/// Restrict the returned results to volumes that have an available download format
enum DownloadFormat {
  /// Return only volumes with epub download available
  epub,
}
