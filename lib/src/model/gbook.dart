//  Copyright 2020 Bruno D'Luka

import 'extensions.dart';

class Book {
  /// The id of the book
  final String id;
  final String? etag;

  /// A self link containing more especific information
  final Uri? selfLink;

  /// The information about the book
  final BookInfo info;

  /// The information about the book's sale info
  final SaleInfo saleInfo;

  const Book({
    required this.id,
    this.etag,
    required this.info,
    this.selfLink,
    required this.saleInfo,
  });

  @override
  String toString() => '$id:${info.title}';

  static Book fromJson(
    Map<String, dynamic> json, {
    bool reschemeImageLinks = false,
  }) {
    return Book(
      id: json['id'],
      etag: json['etag'],
      info: BookInfo.fromJson(
        json['volumeInfo'],
        reschemeImageLinks: reschemeImageLinks,
      ),
      selfLink: Uri.parse(json['selfLink']),
      saleInfo: SaleInfo.fromJson(json['saleInfo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'etag': etag,
      'selfLink': selfLink?.toString(),
      'info': info.toJson(),
      'saleInfo': saleInfo.toJson(),
    };
  }
}

class IndustryIdentifier {
  final String type;
  final String identifier;

  const IndustryIdentifier({
    required this.type,
    required this.identifier,
  });

  static IndustryIdentifier fromJson(Map<String, dynamic> json) {
    return IndustryIdentifier(
      type: json['type'] ?? '',
      identifier: json['identifier'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'identifier': identifier,
    };
  }

  @override
  String toString() => '$type:$identifier';
}

class SaleInfo {
  final String country;
  final String saleability;
  final bool isEbook;
  final SaleInfoListPrice? listPrice;
  final SaleInfoListPrice? retailPrice;
  final String? buyLink;
  final List<Offer>? offers;

  const SaleInfo({
    required this.country,
    required this.saleability,
    required this.isEbook,
    this.listPrice,
    this.retailPrice,
    this.buyLink,
    this.offers,
  });

  @override
  String toString() =>
      'SaleInfo(country: $country, saleability: $saleability, isEbook: $isEbook, listPrice: $listPrice, retailPrice: $retailPrice, buyLink: $buyLink, offers: $offers)';

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'saleability': saleability,
      'isEbook': isEbook,
      'listPrice': listPrice?.toJson(),
      'retailPrice': retailPrice?.toJson(),
      'buyLink': buyLink,
      'offers': offers?.map((offer) => offer.toJson()).toList(),
    };
  }

  factory SaleInfo.fromJson(Map<String, dynamic> map) {
    return SaleInfo(
      country: map['country'] ?? '',
      saleability: map['saleability'] ?? '',
      isEbook: map['isEbook'] ?? false,
      listPrice:
          map['listPrice'] != null ? SaleInfoListPrice.fromJson(map['listPrice']) : null,
      retailPrice: map['retailPrice'] != null
          ? SaleInfoListPrice.fromJson(map['retailPrice'])
          : null,
      buyLink: map['buyLink'] != null ? map['buyLink'] as String : null,
      offers: map['offers'] != null
          ? (map['offers'] as List).map((offer) => Offer.fromJson(offer)).toList()
          : null,
    );
  }
}

class SaleInfoListPrice {
  final double? amount;
  final String? currencyCode;

  SaleInfoListPrice({
    this.amount,
    this.currencyCode,
  });

  factory SaleInfoListPrice.fromJson(Map<String, dynamic> json) {
    return SaleInfoListPrice(
      amount: (json['amount'] as num?)?.toDouble(),
      currencyCode: json['currencyCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currencyCode': currencyCode,
    };
  }
}

class Offer {
  final int? finskyOfferType;
  final OfferListPrice? listPrice;
  final OfferListPrice? retailPrice;
  final bool? giftable;

  Offer({
    this.finskyOfferType,
    this.listPrice,
    this.retailPrice,
    this.giftable,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      finskyOfferType: json['finskyOfferType'],
      listPrice:
          json['listPrice'] != null ? OfferListPrice.fromJson(json['listPrice']) : null,
      retailPrice: json['retailPrice'] != null
          ? OfferListPrice.fromJson(json['retailPrice'])
          : null,
      giftable: json['giftable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'finskyOfferType': finskyOfferType,
      'listPrice': listPrice?.toJson(),
      'retailPrice': retailPrice?.toJson(),
      'giftable': giftable,
    };
  }
}

class OfferListPrice {
  final int? amountInMicros;
  final String? currencyCode;

  OfferListPrice({
    this.amountInMicros,
    this.currencyCode,
  });

  factory OfferListPrice.fromJson(Map<String, dynamic> json) {
    return OfferListPrice(
      amountInMicros: json['amountInMicros'],
      currencyCode: json['currencyCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amountInMicros': amountInMicros,
      'currencyCode': currencyCode,
    };
  }
}

class BookInfo {
  /// The book title
  final String title;

  /// The book subtitle
  final String subtitle;

  /// A list with the name of all the authors of the book
  final List<String> authors;

  /// The publisher name
  final String publisher;

  /// The date the book was published
  final DateTime? publishedDate;

  /// The date the book was published in raw string format
  final String rawPublishedDate;

  /// The description of the book
  final String description;

  /// The industryIdentifiers of the book (ISBN)
  final List<IndustryIdentifier> industryIdentifiers;

  /// The amount of pages the book has
  final int pageCount;

  /// The categories the book is in
  final List<String> categories;

  /// The average rating
  final double averageRating;

  /// How many people rated the book
  final int ratingsCount;

  /// Wether the book is mature or not
  final String maturityRating;

  /// The content version
  final String contentVersion;

  /// Some image links
  final Map<String, Uri> imageLinks;

  /// The original language of the book
  final String language;

  /// The volume preview link
  final Uri previewLink;

  /// The volume info link
  final Uri infoLink;

  /// The canonical volume link
  final Uri canonicalVolumeLink;

  const BookInfo({
    required this.title,
    required this.subtitle,
    required this.authors,
    required this.publisher,
    required this.averageRating,
    required this.categories,
    required this.contentVersion,
    required this.description,
    required this.industryIdentifiers,
    required this.imageLinks,
    required this.language,
    required this.maturityRating,
    required this.pageCount,
    required this.publishedDate,
    required this.rawPublishedDate,
    required this.ratingsCount,
    required this.previewLink,
    required this.infoLink,
    required this.canonicalVolumeLink,
  });

  static BookInfo fromJson(
    Map<String, dynamic> json, {
    bool reschemeImageLinks = false,
  }) {
    final publishedDateArray =
        ((json['publishedDate'] as String?) ?? '0000-00-00').split('-');

    // initialize datetime variable
    DateTime? publishedDate;
    if (publishedDateArray.isNotEmpty) {
      // initialize date
      int year = int.parse(publishedDateArray[0]);
      int month = 1;
      int day = 1;

      // now test the date string
      if (publishedDateArray.length == 1) {
        // assume we have only the year
        year = int.parse(publishedDateArray[0]);
      }
      if (publishedDateArray.length == 2) {
        // assume we have the year and maybe the month (this could be just a speculative case)
        year = int.parse(publishedDateArray[0]);
        month = int.parse(publishedDateArray[1]);
      }
      if (publishedDateArray.length == 3) {
        // assume we have year-month-day
        year = int.parse(publishedDateArray[0]);
        month = int.parse(publishedDateArray[1]);
        day = int.parse(publishedDateArray[2]);
      }
      publishedDate = DateTime(year, month, day);
    }

    final imageLinks = <String, Uri>{};
    (json['imageLinks'] as Map<String, dynamic>?)?.forEach((key, value) {
      Uri uri = Uri.parse(value.toString());
      if (reschemeImageLinks) {
        if (uri.isScheme('HTTP')) {
          uri = Uri.parse(value.toString().replaceAll('http://', 'https://'));
        }
      }
      imageLinks.addAll({key: uri});
    });

    return BookInfo(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      authors: ((json['authors'] as List<dynamic>?) ?? []).toStringList(),
      publisher: json['publisher'] ?? '',
      averageRating: ((json['averageRating'] ?? 0) as num).toDouble(),
      categories: ((json['categories'] as List<dynamic>?) ?? []).toStringList(),
      contentVersion: json['contentVersion'] ?? '',
      description: json['description'] ?? '',
      language: json['language'] ?? '',
      maturityRating: json['maturityRating'] ?? '',
      pageCount: json['pageCount'] ?? 0,
      ratingsCount: json['ratingsCount'] ?? 0,
      publishedDate: publishedDate,
      rawPublishedDate: (json['publishedDate'] as String?) ?? '',
      imageLinks: imageLinks,
      industryIdentifiers: ((json['industryIdentifiers'] ?? []) as List)
          .map((i) => IndustryIdentifier.fromJson(i))
          .toList(),
      previewLink: Uri.parse(json['previewLink']),
      infoLink: Uri.parse(json['infoLink']),
      canonicalVolumeLink: Uri.parse(json['canonicalVolumeLink']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'authors': authors,
      'publisher': publisher,
      'publishedDate': [
        publishedDate?.year,
        publishedDate?.month,
        publishedDate?.day,
      ],
      'rawPublishedDate': rawPublishedDate,
      'averageRating': averageRating,
      'categories': categories,
      'contentVersion': contentVersion,
      'description': description,
      'language': language,
      'maturityRating': maturityRating,
      'pageCount': pageCount,
      'ratingsCount': ratingsCount,
      'imageLinks': imageLinks.map((key, value) => MapEntry(key, value.toString())),
      'industryIdentifiers':
          industryIdentifiers.map((identifier) => identifier.toJson()).toList(),
      'previewLink': previewLink.toString(),
      'infoLink': infoLink.toString(),
      'canonicalVolumeLink': canonicalVolumeLink.toString(),
    };
  }

  @override
  String toString() {
    return 'BookInfo(title: $title, subtitle: $subtitle authors: $authors, publisher: $publisher, publishedDate: $publishedDate, rawPublishedDate: $rawPublishedDate, description: $description, industryIdentifiers: $industryIdentifiers, pageCount: $pageCount, categories: $categories, averageRating: $averageRating, ratingsCount: $ratingsCount, maturityRating: $maturityRating, contentVersion: $contentVersion, imageLinks: $imageLinks, language: $language, previewLink: $previewLink, infoLink: $infoLink, canonicalVolumeLink: $canonicalVolumeLink)';
  }
}
