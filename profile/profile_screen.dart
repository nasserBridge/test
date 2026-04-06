import 'dart:async';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/constants/image_strings.dart';
import 'package:bridgeapp/src/features/authentication/controllers/profile_controller.dart';
import 'package:bridgeapp/src/common_widgets/popup_yes_no.dart';
import 'package:bridgeapp/src/features/authentication/screens/profile/editform_screen.dart';
import 'package:bridgeapp/src/features/authentication/screens/profile/info_popup.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/repository/authentication_repository/validators.dart';
import 'package:bridgeapp/src/features/authentication/models/user_model.dart';
import 'package:get/get.dart';
import 'package:bridgeapp/src/repository/user_repository/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _userLoading = true;
  late StreamSubscription<UserModel> _streamUserData;
  late StreamSubscription<String> _streamBool;
  UserModel? _user;

  // ✅ All controllers declared here — no more inline TextEditingControllers
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController address1Controller;
  late TextEditingController address2Controller;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController zipcodeController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();

    _streamUserData = UserRepository.instance.userDataStream.listen((data) {
      setState(() {
        _user = data;
        _userLoading = false;
        firstNameController = TextEditingController(text: _user?.firstName);
        lastNameController = TextEditingController(text: _user?.lastName);
        address1Controller = TextEditingController(text: _user?.address1);
        address2Controller = TextEditingController(text: _user?.address2);
        cityController = TextEditingController(text: _user?.city);
        stateController = TextEditingController(text: _user?.state);
        zipcodeController = TextEditingController(text: _user?.zipcode);
        emailController = TextEditingController(text: _user?.email);
        phoneController = TextEditingController(text: _user?.phoneNo);
      });
    });

    UserRepository.instance.getUserDetails();

    _streamBool = UserRepository.instance.boolStream.listen((data) {
      if (data == 'First Name') {
        changeEditName();
      } else if (data == 'Physical Address') {
        changeEditAddress();
      } else if (data == 'E-Mail') {
        changeEditContact();
      } else if (data == 'Old Password') {
        changeEditPassword();
      }
    });
  }

  final _controller = Get.put(ProfileController());
  bool editName = false;
  bool editAddress = false;
  bool editContact = false;
  bool editPassword = false;

  void changeEditName() {
    setState(() => editName = !editName);
    debugPrint('pressed');
  }

  void changeEditAddress() {
    setState(() => editAddress = !editAddress);
  }

  void changeEditContact() {
    setState(() => editContact = !editContact);
  }

  void changeEditPassword() {
    setState(() => editPassword = !editPassword);
  }

  @override
  void dispose() {
    // ✅ Dispose all controllers
    firstNameController.dispose();
    lastNameController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    zipcodeController.dispose();
    emailController.dispose();
    phoneController.dispose();
    _streamUserData.cancel();
    _streamBool.cancel();
    UserRepository.instance.disposeListender();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              setState(() {});
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
            ),
          ),
          title: const Image(
            image: AssetImage(greenBridge),
            height: 45,
          ),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton<String>(
              constraints: BoxConstraints(maxWidth: Scale.x(140)),
              color: AppColors.white,
              surfaceTintColor: AppColors.navy,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'Option 1',
                  child: Text('Delete Profile',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.bold,
                        letterSpacing: Scale.x(1),
                        fontSize: Scale.x(12),
                      )),
                  onTap: () {
                    PopupYesNo.showInfoDialog(
                      context,
                      mainText: 'Are you sure you want to delete your profile?',
                      onYesPressed: () {
                        _controller.pushDelete();
                      },
                    );
                  },
                ),
                PopupMenuItem<String>(
                  value: 'Option 2',
                  child: Text('Cancel',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.bold,
                        letterSpacing: Scale.x(1),
                        fontSize: Scale.x(12),
                      )),
                ),
              ],
            ),
          ]),
      body: SingleChildScrollView(
        child: _userLoading
            ? const CircularProgressIndicator.adaptive()
            : Container(
                margin: EdgeInsets.only(
                    top: Scale.x(50), left: Scale.x(35), right: Scale.x(35)),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROFILE',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w600,
                          fontSize: FontSizes.profileTitle,
                        ),
                      ),
                      SizedBox(height: Scale.x(40)),
                      Container(
                        width: double.infinity,
                        height: Scale.x(1),
                        color: AppColors.blue,
                      ),
                      SizedBox(height: Scale.x(5)),
                      Row(
                        children: [
                          Text(
                            'Name',
                            style: TextStyle(
                                letterSpacing: Scale.x(1.5),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Raleway',
                                fontSize: FontSizes.smallTitle,
                                color: AppColors.green),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  editName = !editName;
                                  if (editContact) editContact = false;
                                  if (editPassword) editPassword = false;
                                });
                              },
                              child: Text(
                                editName == false ? 'Edit' : 'Cancel',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontFamily: 'Raleway',
                                  fontWeight: FontWeight.w600,
                                  fontSize: FontSizes.profileEdit,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Scale.x(30)),
                      editName == true
                          ? EditForm(
                              controller1: firstNameController,
                              label1: 'First Name',
                              validator1: (value) {
                                return FormValidators.validateNewFirstName(
                                    _user?.firstName,
                                    _user?.lastName,
                                    lastNameController.text.trim(),
                                    value);
                              },
                              prefixIcon1: Icons.person_outline_rounded,
                              controller2: lastNameController,
                              label2: 'Last Name',
                              validator2: (value) {
                                return FormValidators.validateNewLastName(
                                    _user?.lastName,
                                    _user?.firstName,
                                    firstNameController.text.trim(),
                                    value);
                              },
                              prefixIcon2: Icons.person_outline_rounded,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user!.firstName,
                                  style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: FontSizes.profileInfo,
                                      color: Colors.black.withValues(alpha: .6)),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _user!.lastName,
                                  style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: FontSizes.profileInfo,
                                      color: Colors.black.withValues(alpha: .6)),
                                ),
                                SizedBox(height: Scale.x(30)),
                              ],
                            ),
                      Container(
                        width: double.infinity,
                        height: Scale.x(1),
                        color: AppColors.blue,
                      ),
                      SizedBox(height: Scale.x(5)),
                      Row(
                        children: [
                          Text(
                            'Physical Address',
                            style: TextStyle(
                                letterSpacing: Scale.x(1.5),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Raleway',
                                fontSize: FontSizes.smallTitle,
                                color: AppColors.green),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  editAddress = !editAddress;
                                  if (editName) editName = false;
                                  if (editContact) editContact = false;
                                  if (editPassword) editPassword = false;
                                });
                              },
                              child: Text(
                                editAddress == false ? 'Edit' : 'Cancel',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontFamily: 'Raleway',
                                  fontWeight: FontWeight.w600,
                                  fontSize: FontSizes.profileEdit,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Scale.x(30)),
                      editAddress == true
                          ? EditForm(
                              prefixIcon1: Icons.home_outlined,
                              controller1: address1Controller,
                              label1: 'Physical Address',
                              validator1: (value) {
                                return FormValidators.validateNewAddressLine1(
                                    _user?.address1,
                                    value,
                                    _user?.address2,
                                    address2Controller.text.trim());
                              },
                              prefixIcon2: Icons.home_outlined,
                              controller2: address2Controller,
                              label2: 'Ste, Apt, Other...',
                              validator2: (value) {
                                return FormValidators.validateNewAddressLine2(
                                  _user?.address1,
                                  address1Controller.text.trim(),
                                  _user?.address2,
                                  value,
                                );
                              },
                              // ✅ Using proper controllers instead of inline ones
                              prefixIcon3: Icons.location_city_outlined,
                              controller3: cityController,
                              label3: 'City',
                              validator3: FormValidators.validateCity,
                              prefixIcon4: null,
                              controller4: stateController,
                              label4: 'State',
                              validator4: FormValidators.validateState,
                              prefixIcon5: null,
                              controller5: zipcodeController,
                              label5: 'Zip Code',
                              validator5: FormValidators.validateZipcode,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user!.address1,
                                  style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: FontSizes.profileInfo,
                                      color: Colors.black.withValues(alpha: .6)),
                                ),
                                _user?.address2 == ''
                                    ? SizedBox(height: Scale.x(5))
                                    : Text(
                                        _user!.address2,
                                        style: TextStyle(
                                            fontFamily: 'Raleway',
                                            fontSize: FontSizes.profileInfo,
                                            color:
                                                Colors.black.withValues(alpha: .6)),
                                      ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      _user!.city,
                                      style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: FontSizes.profileInfo,
                                          color: Colors.black.withValues(alpha: .6)),
                                    ),
                                    Text(
                                      ', ${_user!.state} ${_user!.zipcode}',
                                      style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: FontSizes.profileInfo,
                                          color: Colors.black.withValues(alpha: .6)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Scale.x(30)),
                              ],
                            ),
                      Container(
                        width: double.infinity,
                        height: Scale.x(1),
                        color: AppColors.blue,
                      ),
                      SizedBox(height: Scale.x(5)),
                      Row(
                        children: [
                          Text(
                            'Contact Information',
                            style: TextStyle(
                                letterSpacing: Scale.x(1.5),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Raleway',
                                fontSize: FontSizes.smallTitle,
                                color: AppColors.green),
                          ),
                          IconButton(
                            onPressed: () {
                              InfoPopup.showInfoDialog(context);
                            },
                            icon: Icon(
                              Icons.info_outline,
                              size: Scale.x(20),
                              opticalSize: Scale.x(20),
                              color: AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Scale.x(15)),
                      editContact == true
                          ? EditForm(
                              // ✅ Using proper controllers instead of inline ones
                              controller1: emailController,
                              label1: 'E-Mail',
                              validator1: (value) {
                                return FormValidators.validateNewEmail(
                                    _user?.email, value);
                              },
                              prefixIcon1: Icons.mail_outline_rounded,
                              controller2: phoneController,
                              label2: 'Phone Number',
                              validator2: (value) {
                                return FormValidators.validateNewPhoneNumber(
                                    _user?.phoneNo, value);
                              },
                              prefixIcon2: Icons.call_outlined,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user!.email,
                                  style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: FontSizes.profileInfo,
                                      color: Colors.black.withValues(alpha: .6)),
                                ),
                                SizedBox(height: Scale.x(5)),
                                Text(
                                  _user!.phoneNo,
                                  style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: FontSizes.profileInfo,
                                      color: Colors.black.withValues(alpha: .6)),
                                ),
                                SizedBox(height: Scale.x(30)),
                              ],
                            ),
                      Container(
                        width: double.infinity,
                        height: Scale.x(1),
                        color: AppColors.blue,
                      ),
                      SizedBox(height: Scale.x(5)),
                      Row(
                        children: [
                          Text(
                            'Password',
                            style: TextStyle(
                                letterSpacing: Scale.x(1.5),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Raleway',
                                fontSize: FontSizes.smallTitle,
                                color: AppColors.green),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  editPassword = !editPassword;
                                  if (editName) editName = false;
                                  if (editAddress) editAddress = false;
                                  if (editContact) editContact = false;
                                });
                              },
                              child: Text(
                                editPassword == false ? 'Edit' : 'Cancel',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontFamily: 'Raleway',
                                  fontWeight: FontWeight.w600,
                                  fontSize: FontSizes.profileEdit,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Scale.x(30)),
                      editPassword == true
                          ? EditForm(
                              controller1: _controller.oldPassword,
                              label1: 'Old Password',
                              validator1: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                              prefixIcon1: Icons.fingerprint,
                              controller2: _controller.newPassword,
                              label2: 'New Password',
                              validator2: (value) {
                                return FormValidators.validateNewPassword(
                                    _controller.oldPassword.text.trim(), value);
                              },
                              prefixIcon2: Icons.fingerprint,
                              controller3: _controller.confirmNewPassword,
                              label3: 'Confirm Password',
                              validator3: (value) {
                                return FormValidators.validateConfirmPassword(
                                    _controller.newPassword.text.trim(), value);
                              },
                              prefixIcon3: Icons.fingerprint,
                            )
                          : SizedBox(height: Scale.x(40)),
                    ],
                  ),
                )),
      ),
    );
  }
}
