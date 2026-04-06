import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/constants/image_strings.dart';
import 'package:bridgeapp/src/common_widgets/popup_yes_no.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  PrivacySettingsPageState createState() => PrivacySettingsPageState();
}

class PrivacySettingsPageState extends State<PrivacySettingsPage> {
  late User _user;

  bool _editMode = false;
  bool _acceptAllChecked = false;
  bool _acceptAllDataUsage = false;
  bool _marketingCommunications = false;
  bool _dataUse = false;
  bool _anonymizedDataSharing = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _fetchUserConsents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Image(
          image: AssetImage(greenBridge),
          height: Scale.x(45),
        ),
        centerTitle: true,
        actions: [
          SizedBox(
            width: Scale.x(36),
            child: Container(color: AppColors.white),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(
            top: Scale.x(50), left: Scale.x(35), right: Scale.x(35)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRIVACY',
              style: TextStyle(
                color: AppColors.navy,
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w600,
                fontSize: FontSizes.profileTitle,
              ),
            ),
            SizedBox(
              height: Scale.x(40),
            ),
            Container(
              width: double.infinity,
              height: Scale.x(1),
              color: AppColors.blue,
            ),
            SizedBox(height: Scale.x(5)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Data Usage Consents',
                  style: TextStyle(
                      letterSpacing: Scale.x(1.5),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Raleway',
                      fontSize: FontSizes.smallTitle,
                      color: AppColors.green),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _editMode = !_editMode;
                    });
                  },
                  child: Text(
                    _editMode == false ? 'Edit' : 'Cancel',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w600,
                      fontSize: FontSizes.profileEdit,
                    ),
                  ),
                ),
              ],
            ),
            _editMode == false
                ? const SizedBox(width: 0)
                : Column(
                    children: [
                      SizedBox(
                        height: Scale.x(10),
                      ),
                      CheckboxListTile(
                        title: const Text('Anonymized Data Sharing'),
                        value: _anonymizedDataSharing,
                        onChanged: _editMode
                            ? (value) {
                                setState(() {
                                  _anonymizedDataSharing = value!;
                                  _updateAcceptAllDataUsage();
                                });
                              }
                            : null,
                        checkColor: Colors.white,
                        activeColor:
                            _editMode ? AppColors.green : Colors.grey[400],
                        controlAffinity: ListTileControlAffinity.trailing,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        enabled: _editMode,
                      ),
                      CheckboxListTile(
                        title: const Text('Data Use for Improvements'),
                        value: _dataUse,
                        onChanged: _editMode
                            ? (value) {
                                setState(() {
                                  _dataUse = value!;
                                  _updateAcceptAllDataUsage();
                                });
                              }
                            : null,
                        checkColor: Colors.white,
                        activeColor:
                            _editMode ? AppColors.green : Colors.grey[400],
                        controlAffinity: ListTileControlAffinity.trailing,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        enabled: _editMode,
                      ),
                      CheckboxListTile(
                        title: const Text('Marketing Communications'),
                        value: _marketingCommunications,
                        onChanged: _editMode
                            ? (value) {
                                setState(() {
                                  _marketingCommunications = value!;
                                  _updateAcceptAllDataUsage();
                                });
                              }
                            : null,
                        checkColor: Colors.white,
                        activeColor:
                            _editMode ? AppColors.green : Colors.grey[400],
                        controlAffinity: ListTileControlAffinity.trailing,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        enabled: _editMode,
                      ),
                      SizedBox(height: Scale.x(20)),
                      Center(
                        child: SizedBox(
                          width: Scale.x(180), // Adjustable width
                          child: OutlinedButton(
                            onPressed: () {
                              // _showConfirmationDialog();
                              PopupYesNo.showInfoDialog(
                                context,
                                mainText:
                                    'Are you sure you want to change your data usage consents?',
                                onYesPressed: () {
                                  _updateUserConsents();
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _editMode = !_editMode;
                                  });
                                },
                              );
                            },
                            style: ButtonStyle(
                              fixedSize: WidgetStateProperty.all(
                                  Size(Scale.x(180), Scale.x(15))),
                              side: WidgetStateBorderSide.resolveWith(
                                  (states) =>
                                      const BorderSide(color: AppColors.green)),
                              foregroundColor: WidgetStateColor.resolveWith(
                                  (states) => AppColors.green),
                              overlayColor: WidgetStateColor.resolveWith(
                                  (states) => AppColors.navy),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(color: AppColors.green),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchUserConsents() async {
    try {
      final userId = _user.uid;
      final userData = await FirebaseFirestore.instance
          .collection('userConsents')
          .doc(userId)
          .get();
      if (userData.exists) {
        setState(() {
          _acceptAllChecked = userData['acceptAllChecked'] ?? false;
          _acceptAllDataUsage = userData['acceptAllDataUsage'] ?? false;
          _marketingCommunications =
              userData['marketingCommunications'] ?? false;
          _dataUse = userData['dataUse'] ?? false;
          _anonymizedDataSharing = userData['anonymizedDataSharing'] ?? false;
        });
      }
    } catch (error) {
      SnackbarService.show(error.toString(), isError: true);
    }
  }

  Future<void> _updateUserConsents() async {
    try {
      final userId = _user.uid;
      await FirebaseFirestore.instance
          .collection('userConsents')
          .doc(userId)
          .update({
        'acceptAllChecked': _acceptAllChecked,
        'acceptAllDataUsage': _acceptAllDataUsage,
        'marketingCommunications': _marketingCommunications,
        'dataUse': _dataUse,
        'anonymizedDataSharing': _anonymizedDataSharing,
      });
      // Show success message or handle accordingly
    } catch (error) {
      // Show error message or handle accordingly
      SnackbarService.show(error.toString(), isError: true);
    }
  }

  void _updateAcceptAllDataUsage() {
    setState(() {
      _acceptAllDataUsage =
          _marketingCommunications && _dataUse && _anonymizedDataSharing;
    });
  }
}
