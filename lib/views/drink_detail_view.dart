import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jhyapp/constants/textstyle.dart';

class DrinkDetailView extends StatelessWidget {
  final Map<String, dynamic> drink;

  const DrinkDetailView({super.key, required this.drink});

  @override
  Widget build(BuildContext context) {
    final name = _text('name');
    final brand = _text('brand');
    final type = _text('type');
    final category = _text('category');
    final photoUrl = _text('photo_url');
    final date = DateTime.tryParse(_text('date'));
    final rating = drink['rating'];

    return Scaffold(
      backgroundColor: const Color(0xFF171A1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A1D),
        foregroundColor: const Color(0xFFF3F5F7),
        title: Text(
          'Drink details',
          style: titleStyle.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 230,
                  child: photoUrl.isEmpty
                      ? _DrinkImagePlaceholder(type: type)
                      : GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => _ZoomableDrinkPhoto(
                                  photoUrl: photoUrl,
                                  title: name.isEmpty ? 'Drink photo' : name,
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _DrinkImagePlaceholder(type: type),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                name.isEmpty ? 'Unnamed drink' : name,
                style: headingStyle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (brand.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(brand, style: subtitleStyle),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (type.isNotEmpty) _DetailTag(type),
                  if (category.isNotEmpty) _DetailTag(category),
                ],
              ),
              if (rating is num) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFE7C35A),
                      size: 22,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${rating.toString()} / 5',
                      style: titleStyle.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 22),
              _DetailSection(
                title: 'Log details',
                children: [
                  if (drink['abv'] != null)
                    _DetailRow(label: 'Alcohol', value: '${drink['abv']}% ABV'),
                  if (_text('volume').isNotEmpty)
                    _DetailRow(label: 'Volume', value: _text('volume')),
                  if (drink['quantity'] != null)
                    _DetailRow(label: 'Quantity', value: _text('quantity')),
                  if (drink['price'] != null)
                    _DetailRow(label: 'Price', value: '\$${_text('price')}'),
                  if (date != null)
                    _DetailRow(
                      label: 'Date',
                      value: DateFormat('MMMM d, yyyy').format(date),
                    ),
                  if (_text('location').isNotEmpty)
                    _DetailRow(label: 'Location', value: _text('location')),
                ],
              ),
              if (_text('notes').isNotEmpty) ...[
                const SizedBox(height: 16),
                _DetailSection(
                  title: 'Your notes',
                  children: [
                    Text(
                      _text('notes'),
                      style: subtitleStyle.copyWith(
                        color: const Color(0xFFE7EAEE),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _text(String key) => drink[key]?.toString().trim() ?? '';
}

class _ZoomableDrinkPhoto extends StatelessWidget {
  final String photoUrl;
  final String title;

  const _ZoomableDrinkPhoto({required this.photoUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: SizedBox.expand(
            child: Image.network(
              photoUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrinkImagePlaceholder extends StatelessWidget {
  final String type;

  const _DrinkImagePlaceholder({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF292D33),
      child: Center(
        child: Icon(
          type.toLowerCase() == 'wine'
              ? Icons.wine_bar_rounded
              : type.toLowerCase() == 'spirit'
              ? Icons.liquor_rounded
              : Icons.sports_bar_rounded,
          color: const Color(0xFFD97706),
          size: 72,
        ),
      ),
    );
  }
}

class _DetailTag extends StatelessWidget {
  final String label;

  const _DetailTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF292D33),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: subtitleStyle.copyWith(color: const Color(0xFFE7EAEE)),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2227),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF343941)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: subtitleStyle.copyWith(color: const Color(0xFF9AA0A8)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: subtitleStyle.copyWith(color: const Color(0xFFE7EAEE)),
            ),
          ),
        ],
      ),
    );
  }
}
