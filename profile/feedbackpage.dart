import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/constants/image_strings.dart';
import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  FeedbackPageState createState() => FeedbackPageState();
}

class FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false; // prevent double-tap

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final User? user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance.collection('Feedback').add({
        'text': _feedbackController.text.trim(),
        'email': user?.email,
        'uid': user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _feedbackController.clear();

      _showSuccessBanner(); // Better visual feedback

      // Optional: auto-close after submit
      Future.delayed(Duration(milliseconds: 800), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      SnackbarService.show("Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessBanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: Scale.x(24),
            ),
            SizedBox(width: Scale.x(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Thanks for the feedback!',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: FontSizes.profileInfo,
                      fontFamily: 'Raleway',
                    ),
                  ),
                  SizedBox(height: Scale.x(4)),
                  Text(
                    'We read every message.',
                    style: TextStyle(
                      fontSize: FontSizes.profileEdit,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(Scale.x(16)),
        padding: EdgeInsets.symmetric(
          horizontal: Scale.x(16),
          vertical: Scale.x(16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Scale.x(12)),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image(
          image: AssetImage(greenBridge),
          height: Scale.x(45),
        ),
      ),
      body: SingleChildScrollView(
        // prevent keyboard overflow
        padding: EdgeInsets.all(Scale.x(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clear headline
            Text(
              "Help us improve Bridge",
              style: TextStyle(
                fontSize: FontSizes.profileTitle,
                fontWeight: FontWeight.w700,
                fontFamily: 'Raleway',
              ),
            ),

            SizedBox(height: Scale.x(12)),

            // Explicit permission to be critical
            Text(
              "Be honest — what felt confusing, missing, or annoying?",
              style: TextStyle(
                fontSize: FontSizes.smallTitle,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),

            SizedBox(height: Scale.x(32)),

            // Card-style container for visual clarity
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(Scale.x(12)),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              padding: EdgeInsets.all(Scale.x(16)),
              child: TextField(
                controller: _feedbackController,
                maxLines: 8,
                autofocus: true, // keyboard auto-opens
                style: TextStyle(
                  fontSize: FontSizes.smallTitle,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText:
                      'For example: "I didn\'t understand what this number meant..."',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: FontSizes.smallTitle,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            SizedBox(height: Scale.x(32)),

            // Full-width button with loading state
            SizedBox(
              width: double.infinity,
              height: Scale.x(56),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Scale.x(12)),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: Scale.x(20),
                        width: Scale.x(20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.green,
                          ),
                        ),
                      )
                    : Text(
                        'Send to the builders',
                        style: TextStyle(
                          letterSpacing: Scale.x(1.5),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Raleway',
                          fontSize: FontSizes.smallTitle,
                          color: AppColors.green,
                        ),
                      ),
              ),
            ),

            SizedBox(height: Scale.x(16)),

            // Reassurance
            Center(
              child: Text(
                "Chris & the Bridge team read every message.",
                style: TextStyle(
                  fontSize: FontSizes.profileEdit,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
