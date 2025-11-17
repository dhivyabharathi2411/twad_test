import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// TWAD Logo Widget
/// Displays the official Tamil Nadu Water Supply and Drainage Board logo
class TWADLogo extends StatelessWidget {
  final double size;
  final bool showBorder;

  const TWADLogo({
    super.key,
    this.size = AppConstants.logoSize,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showBorder
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppConstants.primaryColor, width: 3),
            )
          : null,
      child: Stack(
        children: [
          // Outer blue ring
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppConstants.primaryColor,
            ),
            child: Center(
              child: Container(
                width: size * 0.83, // Inner circle size
                height: size * 0.83,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.yellow,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Building with columns and dome
                    _buildBuildingIcon(),
                    const SizedBox(height: 4),
                    // Organization name
                    Text(
                      'TAMILNADU',
                      style: TextStyle(
                        fontSize: size * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'WATER SUPPLY',
                      style: TextStyle(
                        fontSize: size * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'AND DRAINAGE',
                      style: TextStyle(
                        fontSize: size * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'BOARD',
                      style: TextStyle(
                        fontSize: size * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Person drawing water from hand pump
                    _buildPersonWithHandPump(),
                  ],
                ),
              ),
            ),
          ),
          // Tamil text on outer ring - top
          Positioned(
            top: size * 0.07,
            left: 0,
            right: 0,
            child: Text(
              'குடிநீர் வடிகால் வாரியம்',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size * 0.05,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Tamil text on outer ring - bottom
          Positioned(
            bottom: size * 0.07,
            left: 0,
            right: 0,
            child: Text(
              'நீரின்றி அமையாது உலகு',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size * 0.05,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the building icon with columns and dome
  Widget _buildBuildingIcon() {
    return Container(
      width: size * 0.2,
      height: size * 0.15,
      child: CustomPaint(painter: BuildingPainter()),
    );
  }

  /// Builds the person drawing water from hand pump
  Widget _buildPersonWithHandPump() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Person in saree
        Container(
          width: size * 0.08,
          height: size * 0.12,
          child: CustomPaint(painter: PersonPainter()),
        ),
        const SizedBox(width: 2),
        // Hand pump
        Container(
          width: size * 0.06,
          height: size * 0.1,
          child: CustomPaint(painter: HandPumpPainter()),
        ),
        const SizedBox(width: 2),
        // Water droplet
        Icon(Icons.water_drop, size: size * 0.08, color: Colors.blue[700]),
      ],
    );
  }
}

/// Custom painter for the building with columns and dome
class BuildingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[700]!
      ..style = PaintingStyle.fill;

    // Main building structure
    final buildingRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.3, size.width, size.height * 0.7),
      const Radius.circular(2),
    );
    canvas.drawRRect(buildingRect, paint);

    // Dome
    final domeRect = Rect.fromLTWH(
      size.width * 0.2,
      0,
      size.width * 0.6,
      size.height * 0.4,
    );
    canvas.drawOval(domeRect, paint);

    // Columns
    final columnPaint = Paint()
      ..color = Colors.blue[800]!
      ..style = PaintingStyle.fill;

    // Left column
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.4,
        size.width * 0.08,
        size.height * 0.6,
      ),
      columnPaint,
    );

    // Right column
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.82,
        size.height * 0.4,
        size.width * 0.08,
        size.height * 0.6,
      ),
      columnPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the person in saree
class PersonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFF8B0000) // Maroon color for saree
      ..style = PaintingStyle.fill;

    // Head
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.2),
      size.width * 0.15,
      paint,
    );

    // Body (saree)
    final bodyPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.35)
      ..lineTo(size.width * 0.7, size.height * 0.35)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..close();
    canvas.drawPath(bodyPath, paint);

    // Arms
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.4,
        size.width * 0.1,
        size.height * 0.3,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.7,
        size.height * 0.4,
        size.width * 0.1,
        size.height * 0.3,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the hand pump
class HandPumpPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[700]!
      ..style = PaintingStyle.fill;

    // Main pump body
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.3, 0, size.width * 0.4, size.height * 0.7),
      paint,
    );

    // Pump handle
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.2,
        size.width * 0.8,
        size.width * 0.1,
      ),
      paint,
    );

    // Water outlet
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.8),
      size.width * 0.15,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
