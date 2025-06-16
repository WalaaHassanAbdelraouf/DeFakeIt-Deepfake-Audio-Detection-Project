import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/theme.dart';

class AudioAnalysisScreen extends StatelessWidget {
  final String audioName;
  final bool isFake;
  final double confidence;
  final String uploadDate;
  final String notes;
  final String format;
  final double size;

  const AudioAnalysisScreen({
    super.key,
    required this.audioName,
    required this.isFake,
    required this.confidence,
    required this.uploadDate,
    required this.notes,
    required this.format,
    required this.size,
  });

  final String facebookUrl = 'https://www.facebook.com';
  final String instagramUrl = 'https://www.instagram.com';
  final String twitterUrl = 'https://www.twitter.com';

  void _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Image.asset(
              isDarkMode ? "assets/images/background_home_transparent.png" : "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios_new,
                            color: isDarkMode ?AppTheme.textColorLightWhite : AppTheme.secondaryColor),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            audioName,
                            style: textTheme.displayMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: 185,
                    height: 185,
                    child: CustomPaint(
                      painter: GradientCircularPainter(
                        strokeWidth: 18.0,
                        percent: confidence,
                        isFake: isFake,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${(confidence * 100).toInt()}%",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: isFake ? Colors.red : Colors.green,
                              ),
                            ),
                            Text(
                              isFake ? loc.fake : loc.real,
                              style: TextStyle(
                                fontSize: 18,
                                color: isFake ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        loc.confidenceLevel,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        confidence >= 0.8
                            ? loc.high
                            : confidence >= 0.5
                            ? loc.medium
                            : loc.low,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: confidence >= 0.8
                              ? Colors.green
                              : confidence >= 0.5
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    loc.analyzedOn(uploadDate),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc.analysisNotes,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      notes,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc.formatAndSize,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "$format, $size",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc.source,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc.uploadedViaApp,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    loc.shareWith,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => _launchURL(facebookUrl),
                        child:
                        Image.asset('assets/images/fb_icon.png', width: 35),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () => _launchURL(instagramUrl),
                        child:
                        Image.asset('assets/images/ig_icon.png', width: 35),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () => _launchURL(twitterUrl),
                        child:
                        Image.asset('assets/images/X_icon.png', width: 35),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Custom Painter with gradient color logic
class GradientCircularPainter extends CustomPainter {
  final double strokeWidth;
  final double percent;
  final bool isFake;

  GradientCircularPainter({
    required this.strokeWidth,
    required this.percent,
    required this.isFake,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final startAngle = -90.0 * 3.1416 / 180.0;
    final sweepAngle = 2 * 3.1416 * percent;

    final colors = isFake
        ? [Colors.red.shade700, Colors.red.shade700]
        : [Colors.green.shade700, Colors.green.shade700];

    final gradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 3.1416 * 2,
      colors: colors,
    );

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    final bgPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..color = Colors.grey.shade300;

    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      startAngle + sweepAngle,
      2 * 3.1416 - sweepAngle,
      false,
      bgPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}