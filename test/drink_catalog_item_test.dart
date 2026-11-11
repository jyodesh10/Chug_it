import 'package:flutter_test/flutter_test.dart';
import 'package:jhyapp/models/drink_catalog_item.dart';

void main() {
  test('parses catalog barcodes as strings, preserving leading zeroes', () {
    final item = DrinkCatalogItem.fromMap({
      'type': 'beer',
      'name': 'Lager',
      'brand': 'Brewery',
      'category': 'Lager',
      'abv': 5,
      'barcode': '0123456789012',
    });

    expect(item.barcode, '0123456789012');
  });

  test('accepts catalog rows without a barcode', () {
    final item = DrinkCatalogItem.fromMap({
      'type': 'beer',
      'name': 'Lager',
      'brand': 'Brewery',
      'category': 'Lager',
      'abv': 5,
    });

    expect(item.barcode, isNull);
  });
}
