class LinkedAccount {
  final String accountId;
  final String name;
  final String institution;
  final String type;
  final String? subtype;
  final String? mask;
  final String balance;

  LinkedAccount({
    required this.accountId,
    required this.name,
    required this.institution,
    required this.type,
    this.subtype,
    this.mask,
    required this.balance,
  });

  factory LinkedAccount.fromMap(Map<String, dynamic> map) {
    return LinkedAccount(
      accountId: map['AccountID'] ?? '',
      name: map['AccountName'] ?? 'Unknown Account',
      institution: map['Institution'] ?? 'Unknown Institution',
      type: map['Type'] ?? 'Unknown',
      subtype: map['SubType'] ?? map['Category'],
      mask: map['Mask'] ?? map['Last4'],
      balance: map['Balance'] ?? '\$0.00',
    );
  }

  /// Create a copy of this account with updated fields
  LinkedAccount copyWith({
    String? accountId,
    String? name,
    String? institution,
    String? type,
    String? subtype,
    String? mask,
    String? balance,
  }) {
    return LinkedAccount(
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      institution: institution ?? this.institution,
      type: type ?? this.type,
      subtype: subtype ?? this.subtype,
      mask: mask ?? this.mask,
      balance: balance ?? this.balance,
    );
  }

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'AccountID': accountId,
      'AccountName': name,
      'Institution': institution,
      'Type': type,
      'SubType': subtype,
      'Mask': mask,
      'Balance': balance,
    };
  }

  @override
  String toString() {
    return 'LinkedAccount(id: $accountId, name: $name, institution: $institution)';
  }
}
