import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_routes.dart';

class AddDrinkView extends StatefulWidget {
  const AddDrinkView({super.key});

  @override
  State<AddDrinkView> createState() => _AddDrinkViewState();
}

class _AddDrinkViewState extends State<AddDrinkView> {
  final List<BeerResult> _matchingBeers = const [
    BeerResult(
      name: 'Octoberfest (2026)',
      brewery: 'Sierra Nevada Brewing Co.',
      colors: [
        Color(0xFF7C2D16),
        Color(0xFFD97706),
        Color(0xFFF59E0B),
      ],
    ),
    BeerResult(
      name: 'Premium Pils',
      brewery: 'Sierra Nevada Brewing Co.',
      colors: [
        Color(0xFF7C2D12),
        Color(0xFFF59E0B),
        Color(0xFFFDE68A),
      ],
    ),
  ];

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
              const Text(
                'Add new drink',
                style: TextStyle(
                  color: Color(0xFFF5F7FA),
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2D31),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Color(0xFF9AA3AF),
                        size: 28,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search beers, breweries...',
                            hintStyle: TextStyle(
                              color: Color(0xFF8F96A0),
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Matching beers',
                style: TextStyle(
                  color: Color(0xFFF5F7FA),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              ..._matchingBeers.map(
                (beer) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: BeerResultTile(beer: beer),
                ),
              ),
              const SizedBox(height: 20),
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
                          children: const [
                            Icon(
                              Icons.add,
                              color: Color(0xFF7DB9FF),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Can't find it? Add new beer",
                              style: TextStyle(
                                color: Color(0xFF7DB9FF),
                                fontSize: 18,
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

class BeerResult {
  final String name;
  final String brewery;
  final List<Color> colors;

  const BeerResult({
    required this.name,
    required this.brewery,
    required this.colors,
  });
}

class BeerResultTile extends StatelessWidget {
  final BeerResult beer;

  const BeerResultTile({super.key, required this.beer});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              painter: BeerCanPainter(beer.colors),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                beer.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFE9EDF1),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                beer.brewery,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF9DA4AD),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BeerCanPainter extends CustomPainter {
  final List<Color> colors;

  const BeerCanPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    final shine = Paint()
      ..color = Colors.white.withValues(alpha: 0.17)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(size.width * 0.22, 0, size.width * 0.12, size.height), shine);

    final accent = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.25, size.height), accent);

    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += size.width / 6) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 4, size.height), stripePaint);
    }

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'BEER',
        style: TextStyle(
          color: Colors.white,
          fontSize: 7,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.3,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, size.height / 2 - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant BeerCanPainter oldDelegate) => oldDelegate.colors != colors;
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
      final tangentEnd = metrics.getTangentForOffset(endDistance < totalLength ? endDistance : totalLength)!.position;
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