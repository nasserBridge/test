class MortgageModel {
  final String? accountID;
  final String? accountNumber;
  final double? currentLateFee;
  final double? escrowBalance;
  final bool? hasPMI;
  final bool? hasPrepaymentPenalty;
  final double? interestRatePercentage;
  final String? interestRateType;
  final double? lastPaymentAmount;
  final String? lastPaymentDate;
  final String? loanTerm;
  final String? loanTypeDescription;
  final String? maturityDate;
  final double? nextMonthlyPayment;
  final String? nextPaymentDueDate;
  final String? originationDate;
  final double? originationPrincipalAmount;

  // NEW FIELDS
  final double? pastDueAmount;
  final Map<String, dynamic>? propertyAddress;
  final double? ytdInterestPaid;
  final double? ytdPrincipalPaid;
  final double? ytdPaid;

  MortgageModel({
    this.accountID,
    this.accountNumber,
    this.currentLateFee,
    this.escrowBalance,
    this.hasPMI,
    this.hasPrepaymentPenalty,
    this.interestRatePercentage,
    this.interestRateType,
    this.lastPaymentAmount,
    this.lastPaymentDate,
    this.loanTerm,
    this.loanTypeDescription,
    this.maturityDate,
    this.nextMonthlyPayment,
    this.nextPaymentDueDate,
    this.originationDate,
    this.originationPrincipalAmount,
    this.pastDueAmount,
    this.propertyAddress,
    this.ytdInterestPaid,
    this.ytdPrincipalPaid,
    this.ytdPaid,
  });

  factory MortgageModel.fromMap(Map<String, dynamic> map) {
    return MortgageModel(
      accountID: map['account_id'],
      accountNumber: map['account_number'],
      currentLateFee: map['current_late_fee'],
      escrowBalance: map['escrow_balance'],
      hasPMI: map['has_pmi'],
      hasPrepaymentPenalty: map['has_prepayment_penalty'],
      interestRatePercentage: map['interest_percentage'],
      interestRateType: map['interest_type'],
      lastPaymentAmount: map['last_payment_amount'],
      lastPaymentDate: map['last_payment_date'],
      loanTerm: map['loan_term'],
      loanTypeDescription: map['loan_type_description'],
      maturityDate: map['maturity_date'],
      nextMonthlyPayment: map['next_monthly_payment'],
      nextPaymentDueDate: map['next_payment_due_date'],
      originationDate: map['origination_date'],
      originationPrincipalAmount: map['origination_principal_amount'],

      // NEW FIELDS
      pastDueAmount: map['past_due_amount'],
      propertyAddress: map['property_address'],
      ytdPaid: map['ytd_paid'],
      ytdInterestPaid: map['ytd_interest_paid'],
      ytdPrincipalPaid: map['ytd_principal_paid'],
    );
  }
}
