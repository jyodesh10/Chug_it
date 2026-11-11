import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jhyapp/app/app_routes.dart';
import 'package:jhyapp/constants/textstyle.dart';
import 'package:jhyapp/models/drink_catalog_item.dart';
import 'package:jhyapp/services/drink_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddDrinkView extends StatefulWidget {
  const AddDrinkView({super.key});

  @override
  State<AddDrinkView> createState() => _AddDrinkViewState();
}

class _AddDrinkViewState extends State<AddDrinkView> {
  static const _recentlySelectedKey = 'add_drink_recently_selected';
  static const _maxRecentlySelected = 8;

  final TextEditingController _searchController = TextEditingController();
  List<DrinkCatalogItem> _results = [];
  List<DrinkCatalogItem> _recentlySelected = [];
  late Future<void> _recentlySelectedLoaded;
  bool _isSearching = false;
  String? _submittedSearchTerm;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _recentlySelectedLoaded = _loadRecentlySelected();
  }

  Future<void> _loadRecentlySelected() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedDrinks =
          preferences.getStringList(_recentlySelectedKey) ?? const [];
      final drinks = savedDrinks
          .map(
            (savedDrink) => DrinkCatalogItem.fromMap(
              Map<String, dynamic>.from(jsonDecode(savedDrink) as Map),
            ),
          )
          .toList();
      if (!mounted) return;
      setState(() {
        _recentlySelected = drinks.take(_maxRecentlySelected).toList();
      });
    } catch (error) {
      if (mounted) _showStorageError(error);
    }
  }

  Future<void> _saveRecentlySelected() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(
        _recentlySelectedKey,
        _recentlySelected
            .map(
              (drink) => jsonEncode({
                'type': drink.type,
                'name': drink.name,
                'brand': drink.brand,
                'barcode': drink.barcode,
                'category': drink.category,
                'abv': drink.abv,
              }),
            )
            .toList(),
      );
    } catch (error) {
      if (mounted) _showStorageError(error);
    }
  }

  void _showStorageError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unable to update recently selected drinks: $error'),
      ),
    );
  }

  Future<void> _recordRecentlySelected(DrinkCatalogItem drink) async {
    await _recentlySelectedLoaded;
    if (!mounted) return;
    final drinkKey = _drinkKey(drink);
    final updatedDrinks = [
      drink,
      ..._recentlySelected.where((selected) => _drinkKey(selected) != drinkKey),
    ].take(_maxRecentlySelected).toList();
    setState(() {
      _recentlySelected = updatedDrinks;
    });
    await _saveRecentlySelected();
  }

  String _drinkKey(DrinkCatalogItem drink) =>
      '${drink.type.toLowerCase()}|'
      '${drink.name.trim().toLowerCase()}|'
      '${drink.brand.trim().toLowerCase()}';

  Future<void> _removeRecentlySelected(DrinkCatalogItem drink) async {
    await _recentlySelectedLoaded;
    if (!mounted) return;
    setState(() {
      _recentlySelected.removeWhere(
        (selected) => _drinkKey(selected) == _drinkKey(drink),
      );
    });
    await _saveRecentlySelected();
  }

  Future<void> _clearRecentlySelected() async {
    await _recentlySelectedLoaded;
    if (!mounted) return;
    setState(() {
      _recentlySelected = [];
    });
    await _saveRecentlySelected();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _submittedSearchTerm = null;
      _results = [];
      _searchError = null;
      _isSearching = false;
    });
  }

  void _onSearchSubmitted(String value) {
    final term = value.trim();
    setState(() {
      _submittedSearchTerm = term;
      _results = [];
      _searchError = null;
      _isSearching = term.isNotEmpty;
    });
    if (term.isNotEmpty) {
      _searchCatalog(term);
    }
  }

  Future<void> _searchCatalog(String term) async {
    try {
      final results = await DrinkService.searchDrinkCatalog(term);
      if (!mounted ||
          _searchController.text.trim() != term ||
          _submittedSearchTerm != term) {
        return;
      }
      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (error) {
      if (!mounted ||
          _searchController.text.trim() != term ||
          _submittedSearchTerm != term) {
        return;
      }
      setState(() {
        _searchError = error.toString().replaceFirst('Exception: ', '');
        _results = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _selectDrink(DrinkCatalogItem drink) async {
    await _recordRecentlySelected(drink);
    if (!mounted) return;
    context.push(AppRoutes.newDrink, extra: drink);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171A1D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 26),
              Text(
                'Add new drink',
                style: headingStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2D31),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          onSubmitted: _onSearchSubmitted,
                          textInputAction: TextInputAction.search,
                          style: titleStyle,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search name, brand...',
                            hintStyle: subtitleStyle.copyWith(
                              color: const Color(0xFF8F96A0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 36,
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 0,
                        child: Icon(Icons.search, color: Color(0xFF9AA3AF)),
                      ),
                      if (_searchController.text.isNotEmpty)
                        Positioned(
                          right: -12,
                          child: IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _searchController.text.trim().isEmpty &&
                            _recentlySelected.isNotEmpty
                        ? 'Recently selected'
                        : 'Drink catalog',
                    style: subheadingStyle.copyWith(letterSpacing: -0.3),
                  ),
                  if (_searchController.text.trim().isEmpty &&
                      _recentlySelected.isNotEmpty)
                    TextButton(
                      onPressed: _clearRecentlySelected,
                      child: Text(
                        'Clear',
                        style: subtitleStyle.copyWith(
                          color: const Color(0xFF7DB9FF),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _searchError != null
                    ? Center(
                        child: Text(
                          _searchError!,
                          style: subtitleStyle,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _searchController.text.trim().isEmpty
                    ? _recentlySelected.isEmpty
                          ? Center(
                              child: Text(
                                'Search by drink name or brand.',
                                style: subtitleStyle,
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: _recentlySelected.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final drink = _recentlySelected[index];
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _CatalogResultTile(
                                        drink: drink,
                                        onTap: () => _selectDrink(drink),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Remove recently selected drink',
                                      onPressed: () =>
                                          _removeRecentlySelected(drink),
                                      icon: const Icon(
                                        Icons.close,
                                        color: Color(0xFF9DA4AD),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                    : _submittedSearchTerm != _searchController.text.trim()
                    ? Center(
                        child: Text(
                          'Press search to find drinks.',
                          style: subtitleStyle,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _results.isEmpty
                    ? Center(
                        child: Text(
                          'No matching drinks found. You can add it below.',
                          style: subtitleStyle,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: _results.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) => _CatalogResultTile(
                          drink: _results[index],
                          onTap: () => _selectDrink(_results[index]),
                        ),
                      ),
              ),
              const SizedBox(height: 14),
              CustomPaint(
                painter: DashedBorderPainter(
                  color: const Color(0xFF7A808B),
                  strokeWidth: 1.4,
                  dashWidth: 8,
                  dashSpace: 6,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => context.push(AppRoutes.newDrink),
                    child: SizedBox(
                      height: 62,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add,
                              color: Color(0xFF7DB9FF),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Can't find it? Add new drink",
                              style: titleStyle.copyWith(
                                color: const Color(0xFF7DB9FF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogResultTile extends StatelessWidget {
  final DrinkCatalogItem drink;
  final VoidCallback onTap;

  const _CatalogResultTile({required this.drink, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1F2227),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B3440),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(switch (drink.type) {
                  'wine' => Icons.wine_bar_outlined,
                  'spirit' => Icons.liquor_outlined,
                  _ => Icons.sports_bar_outlined,
                }, color: const Color(0xFF7DB9FF)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drink.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${drink.brand} · ${drink.category}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: subtitleStyle.copyWith(
                        color: const Color(0xFF9DA4AD),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      drink.abv > 0 ? '${drink.abv}% ABV' : 'ABV not listed',
                      style: subtitleStyle,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9DA4AD)),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  const DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(18),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics().first;
    final totalLength = metrics.length;
    double distance = 0;

    while (distance < totalLength) {
      final endDistance = distance + dashWidth;
      final tangentStart = metrics.getTangentForOffset(distance)!.position;
      final tangentEnd = metrics
          .getTangentForOffset(
            endDistance < totalLength ? endDistance : totalLength,
          )!
          .position;
      canvas.drawLine(tangentStart, tangentEnd, paint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}
