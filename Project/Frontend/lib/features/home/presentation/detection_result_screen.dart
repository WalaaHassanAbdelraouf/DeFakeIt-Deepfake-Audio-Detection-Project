import 'package:defakeit/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';  // لازم تولد ملفات الترجمة
import '../../../core/APIs/post_feedback.dart';

class DetectionResultScreen extends StatelessWidget {
  final bool isFake;
  final double confidence;
  final String audioName;
  final String uploadDate;
  final String? message;

  const DetectionResultScreen({
    super.key,
    required this.isFake,
    required this.confidence,
    required this.audioName,
    required this.uploadDate,
    this.message,
  });

  String _getConfidenceLevel(BuildContext context) {
    final percentage = confidence * 100;
    final loc = AppLocalizations.of(context)!;
    if (percentage >= 75) return loc.high;
    if (percentage <= 59) return loc.low;
    return loc.normal;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final confidencePercentage = (confidence * 100).toStringAsFixed(0);
    final color = isFake ? Colors.red : Colors.green;

    final loc = AppLocalizations.of(context)!;

    final resultText = isFake ? loc.fake : loc.real;
    final description = isFake
        ? loc.detectedUnusualPitchChanges
        : loc.authenticAudioDescription;
    final confidenceLevel = _getConfidenceLevel(context);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.black, Colors.grey]
                : [Colors.white, const Color(0xFFF5F5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  loc.detectionResults,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  '${loc.audio}: $audioName',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  '${loc.uploaded}: $uploadDate',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (message != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${loc.message}: $message',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 30),
                CircularPercentIndicator(
                  radius: 80.0,
                  lineWidth: 13.0,
                  percent: confidence.clamp(0.0, 1.0),
                  center: Text(
                    "$confidencePercentage%\n$resultText",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: color),
                    textAlign: TextAlign.center,
                  ),
                  progressColor: color,
                  backgroundColor: Colors.grey.shade200,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Text(
                      '${loc.confidenceLevel}:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      confidenceLevel,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: color, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showFeedbackDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        loc.feedback,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        loc.cancel,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(loc.shareWith),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Image.asset('assets/images/fb_icon.png', width: 35),
                      onPressed: () => _shareResult('facebook'),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: Image.asset('assets/images/ig_icon.png', width: 35),
                      onPressed: () => _shareResult('instagram'),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: Image.asset('assets/images/X_icon.png', width: 35),
                      onPressed: () => _shareResult('x'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    String? feedbackType;
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final loc = AppLocalizations.of(ctx)!;
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text(loc.sendFeedback),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        value: loc.good,
                        groupValue: feedbackType,
                        onChanged: (value) => setState(() => feedbackType = value),
                      ),
                      Text(loc.good),
                      const SizedBox(width: 20),
                      Radio<String>(
                        value: loc.issue,
                        groupValue: feedbackType,
                        onChanged: (value) => setState(() => feedbackType = value),
                      ),
                      Text(loc.issue),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: loc.yourFeedback,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(loc.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (feedbackType == null || controller.text.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(loc.pleaseSelectTypeAndEnterFeedback),
                        ),
                      );
                      return;
                    }

                    final success = await sendFeedback(
                      feedbackType!,
                      controller.text,
                    );

                    Navigator.pop(ctx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(success ? Icons.check : Icons.error,
                                color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              success
                                  ? loc.feedbackSubmittedSuccessfully
                                  : loc.failedToSubmitFeedback,
                            ),
                          ],
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  },
                  child: Text(loc.submit),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _shareResult(String platform) {
    final message = "Detection Result: ${isFake ? "Fake" : "Real"}\n"
        "Confidence: ${(confidence * 100).toStringAsFixed(1)}%\n"
        "Audio: $audioName\n"
        "Uploaded: $uploadDate";

    String url;
    if (platform == 'facebook') {
      url =
      "https://www.facebook.com/sharer/sharer.php?u=https://example.com=$message";
    } else if (platform == 'instagram') {
      url = "https://www.instagram.com/?text=$message";
    } else {
      url = "https://twitter.com/intent/tweet?text=$message";
    }

    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
