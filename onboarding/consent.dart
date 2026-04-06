import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/document_screen.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/document_contents.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/onboarding_controller.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsentScreenState createState() => ConsentScreenState();
}

class ConsentScreenState extends State<ConsentScreen> {
  final _controller = Get.put(OnBoardingController());
  // Create variables to hold the state of each checkbox
  bool _acceptAllChecked = false;
  bool _acceptAllDataUsage = false;
  bool _marketingCommunications = false;
  bool _dataUse = false;
  bool _anonymizedDataSharing = false;
  final ExpansionTileController _controllerTile1 = ExpansionTileController();
  final ExpansionTileController _controllerTile2 = ExpansionTileController();
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    bool allChecked = _acceptAllChecked;
    return Column(
      children: [
        ExpansionTile(
          initiallyExpanded: true,
          controller: _controllerTile1,
          title: const Text(
            'Consents and Agreements',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            ListTile(
              title: Text('Privacy Policy:'),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Emphasize data collection, usage, sharing, and user rights.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: Scale.x(16)),
            ),
            const ListTile(
              title: Text(
                'Terms of Service:',
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Key points on eligibility, account security, and intellectual property.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            ListTile(
              title: Text(
                'End User Licensing Agreement:',
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Licensing terms, use restrictions, and intellectual property rights.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: Scale.x(16)),
            ),
            ListTile(
              title: Text(
                'Cookie Policy:',
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      'How cookies are used to improve user experience and site functionality.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: Scale.x(16)),
            ),
            const ListTile(
              title: Text('Plaid Integration:'),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      'We use Plaid to securely link your financial accounts, providing you with seamless financial management.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Checkbox(
                  value: _acceptAllChecked,
                  onChanged: (value) async {
                    setState(() {
                      _acceptAllChecked = value!;
                    });
                    if (_acceptAllChecked) {
                      // Collapse the ExpansionTile
                      await Future.delayed(const Duration(milliseconds: 350));
                      _controllerTile1.collapse();
                      _controllerTile2.expand();
                    }
                  },
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'I have read and agreed to the ',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        _buildClickableText(
                            'Privacy Policy', DocumentContents.privacyPolicy),
                        const TextSpan(
                          text: ', ',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        _buildClickableText(
                            'Terms of Service', DocumentContents.tosPolicy),
                        const TextSpan(
                          text: ', ',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        _buildClickableText(
                            'EULA', DocumentContents.eulaPolicy),
                        const TextSpan(
                          text: ', ',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        _buildClickableText(
                            'Cookie Policy', DocumentContents.cookiePolicy),
                        const TextSpan(
                          text: ', and ',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        _buildClickableText('Plaid Integration',
                            DocumentContents.plaidIntegration),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: Scale.x(25)),
          ],
        ),
        ExpansionTile(
          controller: _controllerTile2,
          title: const Text(
            'Data Usage Agreement',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            ListTile(
              title: const Text('Data Use for Improvements'),
              subtitle: Row(
                children: [
                  Checkbox(
                    value: _dataUse,
                    onChanged: (value) {
                      setState(() {
                        _dataUse = value!;
                        if (!value) {
                          _acceptAllDataUsage = false;
                        } else {
                          _acceptAllDataUsage = _marketingCommunications &&
                              _anonymizedDataSharing;
                        }
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'I agree to let Bridge use my anonymized data to enhance services and user experience.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: Scale.x(16)),
            ),
            ListTile(
              title: const Text('Anonymized Data Sharing'),
              subtitle: Row(
                children: [
                  Checkbox(
                    value: _anonymizedDataSharing,
                    onChanged: (value) {
                      setState(() {
                        _anonymizedDataSharing = value!;
                        if (!value) {
                          _acceptAllDataUsage = false;
                        } else {
                          _acceptAllDataUsage =
                              _marketingCommunications && _dataUse;
                        }
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'I agree to allow Bridge to share or sell my anonymized data with third parties for analytics, market research or related purposes.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: Scale.x(16)),
            ),
            ListTile(
              title: const Text('Marketing Communications'),
              subtitle: Row(
                children: [
                  Checkbox(
                    value: _marketingCommunications,
                    onChanged: (value) {
                      setState(() {
                        _marketingCommunications = value!;
                        if (!value) {
                          _acceptAllDataUsage = false;
                        } else {
                          _acceptAllDataUsage =
                              _dataUse && _anonymizedDataSharing;
                        }
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Yes, I want to receive updates, tips, and exclusive offers from Bridge.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: Scale.x(16)),
            ),
            Row(
              children: [
                Checkbox(
                  value: _acceptAllDataUsage,
                  onChanged: (value) async {
                    setState(() => _acceptAllDataUsage = value!);
                    if (!value!) {
                      setState(() {
                        _marketingCommunications = false;
                        _dataUse = false;
                        _anonymizedDataSharing = false;
                      });
                    } else {
                      setState(() {
                        _marketingCommunications = true;
                        _dataUse = true;
                        _anonymizedDataSharing = true;
                      });
                      await Future.delayed(const Duration(milliseconds: 350));
                      _controllerTile2.collapse();
                    }
                  },
                ),
                const Expanded(
                  child: Text(
                    'Accept All',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Scale.x(10)),
          ],
        ),
        SizedBox(height: Scale.x(30)),
        ElevatedButton(
          style: ButtonStyle(
            fixedSize: WidgetStateProperty.all(Size(Scale.x(210), Scale.x(15))),
            backgroundColor:
                WidgetStateColor.resolveWith((states) => AppColors.green),
            foregroundColor:
                WidgetStateColor.resolveWith((states) => AppColors.white),
            overlayColor:
                WidgetStateColor.resolveWith((states) => AppColors.navy),
          ),
          onPressed: allChecked
              ? () async {
                  // Get the current user's UID
                  String uid;
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    uid = user.uid;
                    // Run the function to save consent preferences with the UID
                    setState(() => isloading = !isloading);
                    await _controller.completeOnboarding(
                      uid,
                      _acceptAllChecked,
                      _acceptAllDataUsage,
                      _marketingCommunications,
                      _dataUse,
                      _anonymizedDataSharing,
                    );
                    setState(() => isloading = !isloading);
                  }
                }
              : null,
          child: isloading == true
              ? const CircularProgressIndicator.adaptive()
              : Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w600,
                    letterSpacing: Scale.x(1.5),
                  ),
                ),
        ),
        SizedBox(height: Scale.x(30)),
      ],
    );
  }

  TextSpan _buildClickableText(String text, String documentContent) {
    return TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.blue, // Adjust based on your app's theme
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>
                    DocumentScreen(title: text, content: documentContent)),
          );
        },
    );
  }
}
