class UserOnboardingModel {
  String? email;

  UserOnboardingModel({
    this.email,
  });

  UserOnboardingModel copyWith({String? email}) => UserOnboardingModel(
        email: email ?? this.email,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
      };

  factory UserOnboardingModel.fromJson(Map<String, dynamic> json) =>
      UserOnboardingModel(
        email: json['email'] as String?,
      );
}
