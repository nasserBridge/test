final Map<String, dynamic> fakeMortgageData = {
  "account_id": "TEST1234567890",
  "account_number": "9876543210",
  "current_late_fee": 45.00,
  "escrow_balance": 3125.77,
  "has_pmi": false,
  "has_prepayment_penalty": false,
  "interest_rate": {
    "percentage": 4.25,
    "type": "fixed",
  },
  "last_payment_amount": 2378.55,
  "last_payment_date": "2024-12-01",
  "loan_term": "30 year",
  "loan_type_description": "conventional",
  "maturity_date": "2054-12-01",
  "next_month_payment": 2378.55,
  'next_payment_amount': 500,
  "next_payment_due_date": "2025-01-01",
  "origination_date": "2024-01-01",
  "origination_principal_amount": 550000.00,
  "past_due_amount": 5000,
  "ytd_interest_paid": 12500.34,
  "ytd_principal_paid": 15000.00,
  "property_address": {
    "city": "Malakoff",
    "country": "US",
    "postal_code": "14236",
    "region": "NY",
    "street": "2992 Cameron Road",
  },
};


///
// Payment Details Widget at the far right show a "Delinquent" red text flag if plaid provide a flag bool
// Past Due Amount - Title Regular color, amount in Red (only show if amount is available or not 0)
// Late Fee - Title Regular color, amount in Regular color (show only if available)
// Next Payment Amount
// Due Date
// Last Payment As is 
// Paid YTD (YTD Interest + YTD Principal) (Nested Dropdown Section)
// -- YTD Principal
// -- YTD Interest
// Escrow Balance

// Mortgage Details (Collapsible Section)
// Loan Type
// Loan Term
// Origination Date
// Maturity Date
// APR
// PMI
// Prepayment Penalty
// Property Address

