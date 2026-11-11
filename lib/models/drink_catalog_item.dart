class DrinkCatalogItem {
  final String type;
  final String name;
  final String brand;
  final String category;
  final double abv;
  final String? barcode;

  const DrinkCatalogItem({
    required this.type,
    required this.name,
    required this.brand,
    required this.category,
    required this.abv,
    this.barcode,
  });

  factory DrinkCatalogItem.fromMap(Map<String, dynamic> row) {
    return DrinkCatalogItem(
      type: row['type']?.toString() ?? 'beer',
      name: row['name']?.toString() ?? '',
      brand: row['brand']?.toString() ?? '',
      category: row['category']?.toString() ?? '',
      abv: (row['abv'] as num?)?.toDouble() ?? 0,
      barcode: row['barcode']?.toString(),
    );
  }
}
