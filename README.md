<div>
  <h1 align="center">google_books</h1>
</div>

A library to help on the search for books on the [Google Books Api](https://developers.google.com/books/docs/v1/using).

## Usage

First of all, import the library:

```dart
import 'package:google_books/google_books.dart';
```

### Querying books

To query books, just call the function `queryBooks`:

```dart
final List<Book> books = await queryBooks(
 'twilight',
 queryType: QueryType.intitle,
 maxResults: 3,
 printType: PrintType.books,
 orderBy: OrderBy.relevance,
);
```

You can change a few parameters to make your query more specific:

| Parameter          | Description                                | Nullable |
| ------------------ | ------------------------------------------ | -------- |
| queryType          | Keywords to search in particular fields    | Yes      |
| maxResults         | Set the max amount of results              | No       |
| startIndex         | for pagination                             | No       |
| langRestrict       | Retrict the query to a specific language   | Yes      |
| orderBy            | Order the query by newest or relevance     | Yes      |
| printType          | Filter by books, magazines or both         | Yes      |
| reschemeImageLinks | Rescheme image urls from `http` to `https` | No       |

### Books

If you already have a `Book` object, you can call `book.info` to get all the book infos:

```dart
final info = book.info;
```

| Parameter                                       | Description                                 |
| ----------------------------------------------- | ------------------------------------------- |
| title (`String`)                                | Title of the book                           |
| subtitle (`String`)                             | The subtile of the book                     |
| authors (`List<String>`)                        | All the authors names                       |
| publisher (`String`)                            | The publisher name                          |
| publishedDate (`DateTime`)                      | The date it was published                   |
| rawPublishedDate (`String`)                     | The date it was published in raw format     |
| description (`String`)                          | Description of the book                     |
| pageCount (`int`)                               | The amount of pages                         |
| categories (`List<String>`)                     | The categories the book is in               |
| averageRating (`double`)                        | The average rating of the book              |
| ratingsCount (`int`)                            | The amount of people that rated it          |
| maturityRating (`String`)                       | The maturity rating                         |
| contentVersion (`String`)                       | The version of the content                  |
| industryIdentifier (`List<IndustryIdentifier>`) | The identifiers of the book (isbn)          |
| imageLinks (`List<Map<String, Uri>>`)           | The links with the avaiable image resources |
| language (`String`)                             | The language code of the book               |
