import 'dart:typed_data';

import 'package:jhyapp/models/drink_catalog_item.dart';
import 'package:jhyapp/models/drink_draft.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DrinkService {
  static final SupabaseClient _client = Supabase.instance.client;
  static const String _photoBucket = 'drink-photos';
  static const int _maxCatalogSearchVariants = 8;
  static const Map<String, String> _accentFamilies = {
    'a': 'aäàáâãåāăą',
    'c': 'cçćč',
    'd': 'dďđ',
    'e': 'eèéêëēėęě',
    'i': 'iìíîïīį',
    'n': 'nñńň',
    'o': 'oöòóôõøō',
    's': 'sśš',
    'u': 'uüùúûū',
    'y': 'yýÿ',
    'z': 'zžźż',
  };

  static Future<void> addDrink(
    DrinkDraft draft, {
    Uint8List? photoBytes,
    String? photoMimeType,
  }) async {
    _validateDraft(draft);
    String? uploadedPhotoPath;

    try {
      String? photoUrl;
      if (photoBytes != null) {
        if (photoBytes.length > 5 * 1024 * 1024) {
          throw Exception('Photo must be 5 MB or smaller.');
        }

        const supportedTypes = {
          'image/jpeg',
          'image/png',
          'image/webp',
          'image/heic',
          'image/heif',
        };
        if (photoMimeType != null && !supportedTypes.contains(photoMimeType)) {
          throw Exception('Choose a JPEG, PNG, WebP, or HEIC photo.');
        }

        final extension = switch (photoMimeType) {
          'image/png' => 'png',
          'image/webp' => 'webp',
          'image/heic' => 'heic',
          'image/heif' => 'heif',
          _ => 'jpg',
        };
        final path =
            'reviews/${DateTime.now().microsecondsSinceEpoch}.$extension';
        final contentType = photoMimeType ?? 'image/jpeg';

        await _client.storage
            .from(_photoBucket)
            .uploadBinary(
              path,
              photoBytes,
              fileOptions: FileOptions(contentType: contentType),
            );
        uploadedPhotoPath = path;
        photoUrl = _client.storage.from(_photoBucket).getPublicUrl(path);
      }

      try {
        final catalogEntry = <String, dynamic>{
          'type': draft.type,
          'name': draft.name.trim(),
          'brand': draft.brand.trim(),
          'category': draft.category.trim(),
          'abv': draft.abv,
        };
        final barcode = draft.barcode?.trim();
        if (barcode != null && barcode.isNotEmpty) {
          catalogEntry['barcode'] = barcode;
        }
        await _client
            .from('drink_catalog')
            .upsert(catalogEntry, onConflict: 'type,name,brand');
        await _client
            .from('drinks')
            .insert(draft.toSupabaseMap(photoUrl: photoUrl));
      } catch (error) {
        if (uploadedPhotoPath != null) {
          try {
            await _client.storage.from(_photoBucket).remove([
              uploadedPhotoPath,
            ]);
          } catch (cleanupError) {
            throw Exception(
              'Saving the drink failed: $error. '
              'Photo cleanup also failed: $cleanupError',
            );
          }
        }
        rethrow;
      }
    } on PostgrestException catch (error) {
      throw Exception('Supabase error: ${error.message}');
    } on StorageException catch (error) {
      throw Exception('Photo upload failed: ${error.message}');
    } on Exception {
      rethrow;
    } catch (error) {
      throw Exception('Unable to save drink or photo: $error');
    }
  }

  static Future<List<DrinkCatalogItem>> searchDrinkCatalog(
    String searchTerm,
  ) async {
    final term = searchTerm.trim();
    if (term.isEmpty) return const [];

    try {
      final searchTerms = _searchTermVariants(term);
      final filters = searchTerms
          .expand((searchTerm) {
            final escapedTerm = searchTerm
                .replaceAll(r'\', r'\\')
                .replaceAll('"', r'\"');
            final pattern = '"%$escapedTerm%"';
            return ['name.ilike.$pattern', 'brand.ilike.$pattern'];
          })
          .join(',');
      final results = await _client
          .from('drink_catalog')
          .select('type, name, brand, category, abv, barcode')
          .or(filters)
          .order('name')
          .limit(1000);

      final uniqueByKey = <String, DrinkCatalogItem>{};
      for (final row in results) {
        final item = DrinkCatalogItem.fromMap(Map<String, dynamic>.from(row));
        final key =
            '${item.type.toLowerCase()}|'
            '${item.name.trim().toLowerCase()}|'
            '${item.brand.trim().toLowerCase()}';
        uniqueByKey.putIfAbsent(key, () => item);
      }
      return uniqueByKey.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } on PostgrestException catch (error) {
      throw Exception('Unable to search drink catalog: ${error.message}');
    }
  }

  static Future<DrinkCatalogItem?> findDrinkByBarcode(String barcode) async {
    final normalizedBarcode = barcode.trim();
    if (!RegExp(r'^\d{8,14}$').hasMatch(normalizedBarcode)) {
      throw ArgumentError.value(
        barcode,
        'barcode',
        'A barcode must contain 8 to 14 digits.',
      );
    }

    try {
      final result = await _client
          .from('drink_catalog')
          .select('type, name, brand, category, abv, barcode')
          .eq('barcode', normalizedBarcode)
          .maybeSingle();
      if (result == null) return null;
      return DrinkCatalogItem.fromMap(Map<String, dynamic>.from(result));
    } on PostgrestException catch (error) {
      throw Exception('Unable to look up drink barcode: ${error.message}');
    }
  }

  static Set<String> _searchTermVariants(String term) {
    final accentRoots = <String, String>{
      for (final entry in _accentFamilies.entries)
        for (final character in entry.value.split('')) character: entry.key,
    };
    final baseTerm = term
        .toLowerCase()
        .split('')
        .map((character) => accentRoots[character] ?? character)
        .join();
    final seeds = <String>{
      term.toLowerCase(),
      baseTerm,
      baseTerm.replaceAll('ae', 'ä'),
      baseTerm.replaceAll('oe', 'ö'),
      baseTerm.replaceAll('ue', 'ü'),
      baseTerm.replaceAll('ss', 'ß'),
    };
    final variants = <String>{...seeds};

    for (final seed in seeds) {
      final characters = seed.split('');
      final choices = characters.map((character) {
        final family = _accentFamilies[character];
        return family == null ? [character] : family.split('');
      }).toList();

      for (
        var accentCount = 0;
        accentCount <= characters.length &&
            variants.length < _maxCatalogSearchVariants;
        accentCount++
      ) {
        final selectedCharacters = List<String>.filled(characters.length, '');

        bool addVariants(int index, int accentsUsed) {
          if (variants.length >= _maxCatalogSearchVariants) return true;
          if (accentsUsed > accentCount ||
              accentsUsed + characters.length - index < accentCount) {
            return false;
          }
          if (index == characters.length) {
            if (accentsUsed == accentCount) {
              variants.add(selectedCharacters.join());
            }
            return variants.length >= _maxCatalogSearchVariants;
          }

          for (final choice in choices[index]) {
            final isAccent = choice != characters[index];
            selectedCharacters[index] = choice;
            if (addVariants(index + 1, accentsUsed + (isAccent ? 1 : 0))) {
              return true;
            }
          }
          return false;
        }

        if (addVariants(0, 0)) break;
      }
    }

    final searchTerms = <String>{...variants};
    for (final variant in variants.toList()) {
      if (RegExp(r'^[a-z0-9]+s$').hasMatch(variant)) {
        final stem = variant.substring(0, variant.length - 1);
        searchTerms
          ..add("$stem's")
          ..add('$stem’s');
      }
    }
    return searchTerms;
  }

  static Future<List<Map<String, dynamic>>> getDrinksForMonth(
    DateTime month,
  ) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final startDate = _dateOnly(start);
    final endDate = _dateOnly(end);

    try {
      final rows = await _client
          .from('drinks')
          .select(
            'id, type, name, brand, category, abv, volume, quantity, price, '
            'date, rating, notes, photo_url, location',
          )
          .gte('date', startDate)
          .lt('date', endDate)
          .order('date');
      return rows.map((row) => Map<String, dynamic>.from(row)).toList();
    } on PostgrestException catch (error) {
      throw Exception('Unable to load calendar drinks: ${error.message}');
    }
  }

  static Future<List<Map<String, dynamic>>> getRecentDrinks() async {
    try {
      final rows = await _client
          .from('drinks')
          .select(
            'id, type, name, brand, category, abv, volume, quantity, price, '
            'date, rating, notes, photo_url, location',
          )
          .order('date', ascending: false, nullsFirst: false)
          .limit(3);
      return rows.map((row) => Map<String, dynamic>.from(row)).toList();
    } on PostgrestException catch (error) {
      throw Exception('Unable to load recent drinks: ${error.message}');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllDrinksForStats() async {
    try {
      final rows = await _client
          .from('drinks')
          .select('type, name, brand, date, rating, price, flavour_notes')
          .order('date', ascending: false, nullsFirst: false);
      return rows.map((row) => Map<String, dynamic>.from(row)).toList();
    } on PostgrestException catch (error) {
      throw Exception('Unable to load drink statistics: ${error.message}');
    }
  }

  static String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static void _validateDraft(DrinkDraft draft) {
    if (!{'beer', 'wine', 'spirit'}.contains(draft.type)) {
      throw Exception('Choose a supported drink type.');
    }
    if (draft.name.trim().isEmpty || draft.name.length > 100) {
      throw Exception(
        'Drink name is required and must be at most 100 characters.',
      );
    }
    if (draft.brand.trim().isEmpty || draft.brand.length > 100) {
      throw Exception('Brand is required and must be at most 100 characters.');
    }
    if (draft.category.trim().isEmpty || draft.category.length > 100) {
      throw Exception(
        'Category is required and must be at most 100 characters.',
      );
    }
    if (!draft.abv.isFinite || draft.abv < 0 || draft.abv > 100) {
      throw Exception('ABV must be between 0 and 100.');
    }
    final volumeMatch = RegExp(
      r'^(\d+(?:\.\d+)?)\s*(?:ml|cl|l|oz)$',
      caseSensitive: false,
    ).firstMatch(draft.volume.trim());
    final volumeAmount = double.tryParse(volumeMatch?.group(1) ?? '');
    if (volumeMatch == null ||
        volumeAmount == null ||
        !volumeAmount.isFinite ||
        volumeAmount <= 0 ||
        draft.volume.length > 30) {
      throw Exception('Enter a valid volume, such as 350ml or 0.35L.');
    }
    if (draft.quantity < 1 || draft.quantity > 999) {
      throw Exception('Quantity must be between 1 and 999.');
    }
    if (draft.price != null &&
        (!draft.price!.isFinite ||
            draft.price! < 0 ||
            ((draft.price! * 100) - (draft.price! * 100).round()).abs() >
                0.0000001)) {
      throw Exception('Price must be non-negative with at most 2 decimals.');
    }
    if (draft.rating < 1 || draft.rating > 5) {
      throw Exception('Rating must be between 1 and 5.');
    }
    final date = DateTime(draft.date.year, draft.date.month, draft.date.day);
    final today = DateTime.now();
    if (date.isAfter(DateTime(today.year, today.month, today.day)) ||
        date.year < 1900) {
      throw Exception('Choose a valid date that is not in the future.');
    }
    if (draft.location.trim().isEmpty || draft.location.length > 100) {
      throw Exception(
        'Location is required and must be at most 100 characters.',
      );
    }
    if (draft.notes.length > 1000) {
      throw Exception('Notes must be at most 1,000 characters.');
    }
  }
}
