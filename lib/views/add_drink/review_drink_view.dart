import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jhyapp/app/app_routes.dart';
import 'package:jhyapp/constants/textstyle.dart';
import 'package:jhyapp/models/drink_draft.dart';
import 'package:jhyapp/services/drink_service.dart';
import 'package:jhyapp/widgets/custom_text_field.dart';
import 'package:jhyapp/widgets/primary_button.dart';
import 'package:jhyapp/widgets/selection_chip.dart';
import 'package:jhyapp/widgets/star_rating_selector.dart';

class ReviewDrinkView extends StatefulWidget {
  final DrinkDraft? draft;

  const ReviewDrinkView({super.key, this.draft});

  @override
  State<ReviewDrinkView> createState() => _ReviewDrinkViewState();
}

class _ReviewDrinkViewState extends State<ReviewDrinkView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  late final DrinkDraft _draft;
  late final List<String> _flavourNotes;
  Uint8List? _photoBytes;
  String? _photoMimeType;
  bool _isSubmitting = false;
  bool _isPickingPhoto = false;
  int _rating = 4;
  final List<String> _selectedFlavours = [];

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ?? DrinkDraft.empty();
    _notesController.text = _draft.notes;
    _locationController.text = _draft.location;
    _rating = _draft.rating;
    _flavourNotes = switch (_draft.type.toLowerCase()) {
      'wine' => const [
        'Fruity',
        'Berry',
        'Citrus',
        'Floral',
        'Oak',
        'Vanilla',
        'Earthy',
        'Dry',
        'Sweet',
        'Tannic',
      ],
      'spirit' => const [
        'Vanilla',
        'Oak',
        'Caramel',
        'Spicy',
        'Smoky',
        'Fruity',
        'Honey',
        'Citrus',
        'Floral',
        'Nutty',
      ],
      _ => const [
        'Hoppy',
        'Malt',
        'Bitter',
        'Citrus',
        'Tropical fruit',
        'Floral',
        'Pine',
        'Roasted',
        'Caramel',
        'Crisp',
      ],
    };
    _selectedFlavours.addAll(_draft.flavourNotes);
  }

  Future<void> _pickPhoto() async {
    if (_isPickingPhoto || _isSubmitting) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1F2227),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    setState(() => _isPickingPhoto = true);
    try {
      final photo = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 55,
      );
      if (photo == null) return;

      final photoBytes = await photo.readAsBytes();
      if (!mounted) return;
      if (photoBytes.length > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compressed photo must be 2 MB or smaller')),
        );
        return;
      }

      setState(() {
        _photoBytes = photoBytes;
        _photoMimeType = photo.mimeType;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to select photo: $error')));
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  Future<void> _submitReview() async {
    if (_isSubmitting || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);

    final payload = _draft.copyWith(
      notes: _notesController.text.trim(),
      rating: _rating,
      flavourNotes: _selectedFlavours,
      location: _locationController.text.trim(),
    );

    try {
      await DrinkService.addDrink(
        payload,
        photoBytes: _photoBytes,
        photoMimeType: _photoMimeType,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Drink saved to Supabase')));
      context.go(AppRoutes.home);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171A1D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _draft.brand.isNotEmpty ? _draft.brand : 'Carlsberg Group',
                style: subtitleStyle.copyWith(color: const Color(0xFF8E939A)),
              ),
              const SizedBox(height: 6),
              Text(
                _draft.name.isNotEmpty ? _draft.name : 'Tuborg',
                style: headingStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_draft.type[0].toUpperCase()}${_draft.type.substring(1)}'
                ' · ${_draft.category}',
                style: subtitleStyle,
              ),
              const SizedBox(height: 4),
              Text(
                '${_draft.abv}% ABV · ${_draft.volume} · Qty ${_draft.quantity}'
                '${_draft.price == null ? '' : ' · \$${_draft.price!.toStringAsFixed(2)}'}',
                style: subtitleStyle,
              ),
              const SizedBox(height: 4),
              Text(
                'Drank on ${_draft.date.toIso8601String().split('T').first}',
                style: subtitleStyle,
              ),
              const SizedBox(height: 26),
              Text('Your rating', style: titleStyle),
              const SizedBox(height: 14),
              StarRatingSelector(
                rating: _rating,
                onChanged: (value) => setState(() => _rating = value),
              ),
              const SizedBox(height: 22),
              Text('Favour notes', style: titleStyle),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _flavourNotes.map((flavour) {
                  final selected = _selectedFlavours.contains(flavour);
                  return SelectionChip(
                    label: flavour,
                    isSelected: selected,
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedFlavours.remove(flavour);
                        } else {
                          _selectedFlavours.add(flavour);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Where',
                      hintText: 'e.g. Home',
                      controller: _locationController,
                      validator: (value) {
                        final location = value?.trim() ?? '';
                        if (location.isEmpty) return 'Location is required';
                        if (location.length > 100) {
                          return 'Location must be 100 characters or fewer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'Notes (optional)',
                      hintText: 'How was it?',
                      controller: _notesController,
                      maxLines: 3,
                      minLines: 3,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      validator: (value) {
                        if ((value?.length ?? 0) > 1000) {
                          return 'Notes must be 1,000 characters or fewer';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text('Add a photo', style: titleStyle),
              const SizedBox(height: 14),
              DottedUploadBox(
                imageBytes: _photoBytes,
                onTap: _isPickingPhoto || _isSubmitting ? null : _pickPhoto,
                onRemove: () {
                  setState(() {
                    _photoBytes = null;
                    _photoMimeType = null;
                  });
                },
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: _isSubmitting ? 'Posting...' : 'Post review',
                onPressed: _isSubmitting ? null : _submitReview,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DottedUploadBox extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback? onTap;
  final VoidCallback onRemove;

  const DottedUploadBox({
    super.key,
    required this.imageBytes,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6F787F),
            width: 1.5,
            style: BorderStyle.solid,
          ),
          color: Colors.transparent,
        ),
        child: Center(
          child: CustomPaint(
            painter: _DashedBorderPainter(),
            child: SizedBox(
              width: 160,
              height: 120,
              child: imageBytes == null
                  ? const Center(
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 38,
                        color: Color(0xFFE7EAEE),
                      ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(imageBytes!, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            onPressed: onRemove,
                            icon: const Icon(Icons.close),
                            color: Colors.white,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              minimumSize: const Size(32, 32),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6F787F)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics().first;
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double distance = 0;

    while (distance < metrics.length) {
      final start = metrics.getTangentForOffset(distance)!.position;
      final end = metrics
          .getTangentForOffset(
            (distance + dashWidth).clamp(0.0, metrics.length),
          )!
          .position;
      canvas.drawLine(start, end, paint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
