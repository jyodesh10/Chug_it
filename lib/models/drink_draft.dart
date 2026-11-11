class DrinkDraft {
  final String type;
  final String name;
  final String brand;
  final String? barcode;
  final String category;
  final double abv;
  final String volume;
  final int quantity;
  final double? price;
  final DateTime date;
  final int rating;
  final String notes;
  final List<String> flavourNotes;
  final String location;

  const DrinkDraft({
    required this.type,
    required this.name,
    required this.brand,
    this.barcode,
    required this.category,
    required this.abv,
    required this.volume,
    required this.quantity,
    this.price,
    required this.date,
    required this.rating,
    required this.notes,
    required this.flavourNotes,
    required this.location,
  });

  DrinkDraft.empty()
    : type = 'beer',
      name = '',
      brand = '',
      barcode = null,
      category = '',
      abv = 6.5,
      volume = '350ml',
      quantity = 1,
      price = null,
      date = DateTime.now(),
      rating = 4,
      notes = '',
      flavourNotes = const [],
      location = 'Home';

  DrinkDraft copyWith({
    String? type,
    String? name,
    String? brand,
    String? barcode,
    String? category,
    double? abv,
    String? volume,
    int? quantity,
    double? price,
    DateTime? date,
    int? rating,
    String? notes,
    List<String>? flavourNotes,
    String? location,
  }) {
    return DrinkDraft(
      type: type ?? this.type,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      abv: abv ?? this.abv,
      volume: volume ?? this.volume,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      date: date ?? this.date,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      flavourNotes: flavourNotes ?? this.flavourNotes,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toSupabaseMap({String? photoUrl}) {
    return {
      'type': type,
      'name': name,
      'brand': brand,
      'category': category,
      'abv': abv,
      'volume': volume,
      'quantity': quantity,
      'price': price,
      'date': date.toIso8601String().split('T').first,
      'rating': rating,
      'notes': notes,
      'flavour_notes': flavourNotes,
      'location': location,
      'photo_url': photoUrl,
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}
