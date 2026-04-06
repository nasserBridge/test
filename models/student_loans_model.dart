class StudentLoansModel {
  final String? accountID;
  final String? accountNumber;
  final String? disbursementDate;
  final String? expectedPayoffDate;
  final String? guarantor;
  final double? interestRatePercentage;
  final bool? isOverDue;
  final double? lastPaymentAmount;
  final String? lastPaymentDate;
  final String? lastSatementIssueDate;
  final String? loanName;
  final String? loanStatus;
  final String? endDate;
  final String? type;
  final double? minimumPaymentAmount;
  final String nextPaymentDueDate;
  final String? originationDate;
  final double? originationPrincipalAmount;
  final double? outstandingPrincipalAmount;
  final double? outstandingInterestAmount;
  final double? paymentInterestAmount;
  final String? paymentReferenceNumber;
  final String? estimatedEligibilityDate;
  final String? paymentsMade;
  final String? paymentsRemaining;

  StudentLoansModel({
    this.accountID,
    this.accountNumber,
    this.disbursementDate,
    this.expectedPayoffDate,
    this.guarantor,
    this.interestRatePercentage,
    this.isOverDue,
    this.lastPaymentAmount,
    this.lastPaymentDate,
    this.lastSatementIssueDate,
    this.loanName,
    this.loanStatus,
    this.endDate,
    this.type,
    this.minimumPaymentAmount,
    required this.nextPaymentDueDate,
    this.originationDate,
    this.originationPrincipalAmount,
    this.outstandingPrincipalAmount,
    this.outstandingInterestAmount,
    this.paymentInterestAmount,
    this.paymentReferenceNumber,
    this.estimatedEligibilityDate,
    this.paymentsMade,
    this.paymentsRemaining,
  });

  factory StudentLoansModel.fromMap(Map<String, dynamic> map) {
    return StudentLoansModel(
      accountID: map['account_id'],
      accountNumber: map['account_number'],
      disbursementDate: map['disbursement_date'],
      expectedPayoffDate: map['expected_payoff_date'],
      guarantor: map['guarantor'],
      interestRatePercentage: map['interest_rate_percentage'],
      isOverDue: map['is_overdue'],
      lastPaymentAmount: map['last_payment_amount'],
      lastPaymentDate: map['last_payment_date'],
      lastSatementIssueDate: map['last_statement_issue_date'],
      loanName: map['loan_name'],
      loanStatus: map['loan_status'],
      endDate: map['end_date'],
      type: map['type'],
      minimumPaymentAmount: map['minimum_payment_amount'],
      nextPaymentDueDate: map['next_payment_due_date'],
      originationDate: map['origination_date'],
      originationPrincipalAmount: map['origination_principal_amount'],
      outstandingPrincipalAmount: map['outstanding_principal_amount'],
      outstandingInterestAmount: map['outstanding_interest_amount'],
      paymentInterestAmount: map['payment_interest_amount'],
      paymentReferenceNumber: map['payment_reference_number'],
      estimatedEligibilityDate: map['estimated_eligibility_date'],
      paymentsMade: map['payments_made'],
      paymentsRemaining: map['payments_remaining'],
    );
  }
}
