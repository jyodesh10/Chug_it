import 'package:flutter/material.dart';
import 'package:jhyapp/widgets/custom_text_field.dart';
import 'package:jhyapp/widgets/selection_chip.dart';
import 'package:jhyapp/widgets/star_rating_selector.dart';

class ReviewDrinkView extends StatefulWidget {
  const ReviewDrinkView({super.key});

  @override
  State<ReviewDrinkView> createState() => _ReviewDrinkViewState();
}

class _ReviewDrinkViewState extends State<ReviewDrinkView> {
  final TextEditingController _notesController = TextEditingController();
  int _rating = 4;
  final List<String> _flavourNotes = ['Citrus', 'Hazy', 'Hazy', 'Hazy', 'Hazy'];
  final List<String> _selectedFlavours = ['Hazy'];

  @override
  void dispose() {
    _notesController.dispose();
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
              const Text(
                'Carlsberg Group',
                style: TextStyle(
                  color: Color(0xFF8E939A),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tuborg',
                style: TextStyle(
                  color: Color(0xFFF3F5F7),
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Your rating',
                style: TextStyle(
                  color: Color(0xFFF3F5F7),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              StarRatingSelector(
                rating: _rating,
                onChanged: (value) => setState(() => _rating = value),
              ),
              const SizedBox(height: 22),
              const Text(
                'Favour notes',
                style: TextStyle(
                  color: Color(0xFFF3F5F7),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
              const Text(
                'Where',
                style: TextStyle(
                  color: Color(0xFFF3F5F7),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF7DB5FF),
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Home',
                    style: TextStyle(
                      color: Color(0xFFF3F5F7),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Notes',
                style: TextStyle(
                  color: Color(0xFFF3F5F7),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: '',
                hintText: 'How was it ?',
                controller: _notesController,
                maxLines: 3,
                minLines: 3,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              const SizedBox(height: 18),
              const Text(
                'Add a photo',
                style: TextStyle(
                  color: Color(0xFFF3F5F7),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              DottedUploadBox(
                onTap: () {},
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: const Color(0xFFE5E7EA),
                    foregroundColor: const Color(0xFF171A1D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Post review',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
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

class DottedUploadBox extends StatelessWidget {
  final VoidCallback onTap;

  const DottedUploadBox({super.key, required this.onTap});

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
            child: const SizedBox(
              width: 160,
              height: 120,
              child: Center(
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 38,
                  color: Color(0xFFE7EAEE),
                ),
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
      final end = metrics.getTangentForOffset((distance + dashWidth).clamp(0.0, metrics.length))!.position;
      canvas.drawLine(start, end, paint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
