import 'package:bridgeapp/src/features/authentication/screens/marketplace/marketplace_repository.dart';
import 'dart:math';

final Map<String, List<Map<String, dynamic>>> _categories = {
  'Checkings': [
    {
      'URL':
          'https://promotions.bankofamerica.com/offers/chooseyourchecking300?cm_sp=DEP-Checking-_-ProspectCampaign-_-DCB1HZ6N01_Hero_NH_Checking_Prospect_300Offer_Oct24_G3_MH_mastheadCta',
      'Logo': 'assets/logos/bankofamerica.png',
      'Bank': 'Bank of America',
      'Account': 'Advantage SafeBalance Banking',
      'APY': '0%',
      'Min Opening Balance': '\$25',
      'Bonus Offer': '\$300',
      'Monthly Maintenance Fee': '\$4.95',
      'Fee Waiver Options': {
        'Direct Deposit': null,
        'Daily Balance': '\$500+',
        'Student': true,
        'Transaction Minimum': null,
        'Military': true,
        'Other': true
      },
      'Overdraft Fee': '\$0',
      'ATM Fees': {
        'Out-of-Network': '\$2.50',
        'International': '\$5.00',
      },
      'Foreign Transaction Fee': '3%',
      'Tiered Relationship Program':
          'https://promotions.bankofamerica.com/preferredrewards/en',
    },
    {
      'URL':
          'https://promotions.bankofamerica.com/offers/chooseyourchecking300?cm_sp=DEP-Checking-_-ProspectCampaign-_-DCB1HZ6N01_Hero_NH_Checking_Prospect_300Offer_Oct24_G3_MH_mastheadCta',
      'Logo': 'assets/logos/bankofamerica.png',
      'Bank': 'Bank of America',
      'Account': 'Advantage Plus Banking',
      'APY': '0%',
      'Min Opening Balance': '\$100',
      'Bonus Offer': '\$300',
      'Monthly Maintenance Fee': '\$12',
      'Fee Waiver Options': {
        'Direct Deposit': '\$250',
        'Daily Balance': '\$1,500+',
        'Student': false,
        'Transaction Minimum': null,
        'Military': true,
        'Other': true
      },
      'Overdraft Fee': '\$10',
      'ATM Fees': {
        'Out-of-Network': '\$2.50',
        'International': '\$5.00',
      },
      'Foreign Transaction Fee': '3%',
      'Tiered Relationship Program':
          'https://promotions.bankofamerica.com/preferredrewards/en',
    },
    {
      'URL':
          'https://promotions.bankofamerica.com/offers/chooseyourchecking300?cm_sp=DEP-Checking-_-ProspectCampaign-_-DCB1HZ6N01_Hero_NH_Checking_Prospect_300Offer_Oct24_G3_MH_mastheadCta',
      'Logo': 'assets/logos/bankofamerica.png',
      'Bank': 'Bank of America',
      'Account': 'Advantage Relationship Banking',
      'APY': '0.01%',
      'Min Opening Balance': '\$100',
      'Bonus Offer': '\$300',
      'Monthly Maintenance Fee': '\$25',
      'Fee Waiver Options': {
        'Direct Deposit': null,
        'Daily Balance': '\$20,000+',
        'Student': false,
        'Transaction Minimum': null,
        'Military': true,
        'Other': true
      },
      'Overdraft Fee': '\$10',
      'ATM Fees': {
        'Out-of-Network': '\$2.50',
        'International': '\$5.00',
      },
      'Foreign Transaction Fee': '3%',
      'Tiered Relationship Program':
          'https://promotions.bankofamerica.com/preferredrewards/en',
    },
    {
      'URL':
          'https://account.chase.com/consumer/banking/secure?jp_aid_a=T_88094&jp_aid_p=retail_checking_hp/tile',
      'Logo': 'assets/logos/chase.png',
      'Bank': 'Chase',
      'Account': 'Secure Banking',
      'APY': '0%',
      'Min Opening Balance': '\$0',
      'Bonus Offer': '\$100',
      'Monthly Maintenance Fee': '\$4.95',
      'Fee Waiver Options': {
        'Direct Deposit': '\$250',
        'Daily Balance': null,
        'Student': false,
        'Transaction Minimum': null,
        'Military': false,
        'Other': false
      },
      'Overdraft Fee': '\$0',
      'ATM Fees': {
        'Out-of-Network': '\$3.00',
        'International': '\$5.00',
      },
      'Foreign Transaction Fee': '3%',
      'Tiered Relationship Program': null,
    },
    {
      'URL':
          'https://account.chase.com/consumer/banking/secure?jp_aid_a=T_88094&jp_aid_p=retail_checking_hp/tile',
      'Logo': 'assets/logos/chase.png',
      'Bank': 'Chase',
      'Account': 'Total Checking',
      'APY': '0%',
      'Min Opening Balance': '\$0',
      'Bonus Offer': '\$100',
      'Monthly Maintenance Fee': '\$12',
      'Fee Waiver Options': {
        'Direct Deposit': '\$500',
        'Daily Balance': '\$1,500+',
        'Student': false,
        'Transaction Minimum': null,
        'Military': false,
        'Other': true
      },
      'Overdraft Fee': '\$34',
      'ATM Fees': {
        'Out-of-Network': '\$3.00',
        'International': '\$5.00',
      },
      'Foreign Transaction Fee': '3%',
      'Tiered Relationship Program': null,
    },
    {
      'URL':
          'https://account.chase.com/consumer/banking/secure?jp_aid_a=T_88094&jp_aid_p=retail_checking_hp/tile',
      'Logo': 'assets/logos/chase.png',
      'Bank': 'Chase',
      'Account': 'Premier Plus Checking',
      'APY': '0.01%',
      'Min Opening Balance': '\$0',
      'Bonus Offer': '\$100',
      'Monthly Maintenance Fee': '\$25',
      'Fee Waiver Options': {
        'Direct Deposit': null,
        'Daily Balance': '\$15,000+',
        'Student': false,
        'Transaction Minimum': null,
        'Military': true,
        'Other': true
      },
      'Overdraft Fee': '\$34',
      'ATM Fees': {
        'Out-of-Network': '\$3.00',
        'International': '\$5.00',
      },
      'Foreign Transaction Fee': '3%',
      'Tiered Relationship Program': null,
    },
    {
      'URL':
          'https://account.chase.com/consumer/banking/secure?jp_aid_a=T_88094&jp_aid_p=retail_checking_hp/tile',
      'Logo': 'assets/logos/chase.png',
      'Bank': 'Chase',
      'Account': 'High School Checking',
      'APY': '0%',
      'Min Opening Balance': '\$0',
      'Bonus Offer': '\$100',
      'Monthly Maintenance Fee': '\$0',
      'Fee Waiver Options': {
        'Direct Deposit': null,
        'Daily Balance': null,
        'Student': true,
        'Transaction Minimum': null,
        'Military': false,
        'Other': false
      },
      'Overdraft Fee': '\$0',
      'ATM Fees': {
        'Out-of-Network': '\$3.00',
        'International': '\$5.00',
      },
      'Foreign Transaction Fee': '3%',
      'Tiered Relationship Program': null,
    },
    {
      'URL':
          'https://account.chase.com/consumer/banking/secure?jp_aid_a=T_88094&jp_aid_p=retail_checking_hp/tile',
      'Logo': 'assets/logos/chase.png',
      'Bank': 'Chase',
      'Account': 'College Checking',
      'APY': '0%',
      'Min Opening Balance': '\$0',
      'Bonus Offer': '\$100',
      'Monthly Maintenance Fee': '\$12',
      'Fee Waiver Options': {
        'Direct Deposit': '\$500',
        'Daily Balance': '\$1,500+',
        'Student': true,
        'Transaction Minimum': null,
        'Military': false,
        'Other': false
      },
      'Overdraft Fee': '\$34',
      'ATM Fees': {
        'Out-of-Network': '\$3.00',
        'International': '\$5.00',
      },
      'Foreign Transaction Fee': '3%',
      'Tiered Relationship Program': null,
    },
    {
      'URL': 'https://www.wellsfargo.com/checking/compare-checking-accounts/',
      'Logo': 'assets/logos/wellsfargo.png',
      'Bank': 'Wells Fargo',
      'Account': 'Clear Access Banking',
      'APY': '0%',
      'Min Opening Balance': '\$25',
      'Bonus Offer': '\$0',
      'Monthly Maintenance Fee': '\$5',
      'Fee Waiver Options': {
        'Direct Deposit': null,
        'Daily Balance': null,
        'Student': true,
        'Transaction Minimum': null,
        'Military': true,
        'Other': true
      },
      'Overdraft Fee': '\$0',
      'ATM Fees': {
        'Out-of-Network': '\$3.00',
        'International': '\$5.00',
      },
      'Foreign Transaction Fee': '3%',
      'Tiered Relationship Program': null,
    },
    {
      'URL':
          'https://accountoffers.wellsfargo.com/checkingoffer/?product_code=CHK&subproduct_code=RC&sub_channel=SEM&vendor_code=G&collateral_code=25_Always+On_CSBB_25_CBD_DAQ_BRN_KT_COM_Checking+Core&dm=wells+fargo+checking&&gad_source=1&gclid=Cj0KCQjwkZm_BhDrARIsAAEbX1GJvtvH1KqEE-Sc63yQy7PRbG5aGUb2VK9I0wG2KXOWHQxXH_UX9z4aAlJ-EALw_wcB&gclsrc=aw.ds',
      'Logo': 'assets/logos/wellsfargo.png',
      'Bank': 'Wells Fargo',
      'Account': 'Everyday Checking',
      'APY': '0%',
      'Min Opening Balance': '\$25',
      'Bonus Offer': '\$300',
      'Monthly Maintenance Fee': '\$10',
      'Fee Waiver Options': {
        'Direct Deposit': '\$500',
        'Daily Balance': '\$500+',
        'Student': true,
        'Transaction Minimum': null,
        'Military': true,
        'Other': true
      },
      'Overdraft Fee': '\$35',
      'ATM Fees': {
        'Out-of-Network': '\$3.00',
        'International': '\$5.00',
      },
      'Foreign Transaction Fee': '3%',
      'Tiered Relationship Program': null,
    },
    {
      'URL': 'https://www.wellsfargo.com/checking/compare-checking-accounts/',
      'Logo': 'assets/logos/wellsfargo.png',
      'Bank': 'Wells Fargo',
      'Account': 'Prime Checking',
      'APY': '0.01%',
      'Min Opening Balance': '\$25',
      'Bonus Offer': '\$0',
      'Monthly Maintenance Fee': '\$25',
      'Fee Waiver Options': {
        'Direct Deposit': null,
        'Daily Balance': null,
        'Student': null,
        'Transaction Minimum': null,
        'Military': false,
        'Other': true
      },
      'Overdraft Fee': '\$35',
      'ATM Fees': {
        'Out-of-Network': '\$0.00',
        'International': '\$0.00',
      },
      'Foreign Transaction Fee': '3%',
      'Tiered Relationship Program': null,
    },
    {
      'URL':
          'https://banking.citi.com/cbol/OM/checking/enhanced-direct-deposit-offer/default.htm?venue=GoogleBR&cmp=knc_acquire_2308_BAUCHK_Google_BR&gad_source=1&gclid=Cj0KCQjwkZm_BhDrARIsAAEbX1HP8fuTlQY4Qp0KmKrlvoTSE0TTAOmm_yy5I9WHwB6uPPGZFXT1e6AaAmn9EALw_wcB&gclsrc=aw.ds&BT_TX=1&ProspectID=22520D407F7147B1A6470981B0B9EF1B',
      'Logo': 'assets/logos/citibank.png',
      'Bank': 'Citi Bank',
      'Account': 'Access Checking',
      'APY': '0%',
      'Min Opening Balance': '\$0',
      'Bonus Offer': '\$325',
      'Monthly Maintenance Fee': '\$5',
      'Fee Waiver Options': {
        'Direct Deposit': '\$250',
        'Daily Balance': null,
        'Student': null,
        'Transaction Minimum': null,
        'Military': false,
        'Other': true
      },
      'Overdraft Fee': '\$0',
      'ATM Fees': {
        'Out-of-Network': '\$2.50',
        'International': '\$2.50',
      },
      'Foreign Transaction Fee': '3%',
      'Tiered Relationship Program':
          'https://www.citi.com/banking/compare-bank-accounts',
    },
    {
      'URL':
          'https://banking.citi.com/cbol/OM/checking/enhanced-direct-deposit-offer/default.htm?venue=GoogleBR&cmp=knc_acquire_2308_BAUCHK_Google_BR&gad_source=1&gclid=Cj0KCQjwkZm_BhDrARIsAAEbX1HP8fuTlQY4Qp0KmKrlvoTSE0TTAOmm_yy5I9WHwB6uPPGZFXT1e6AaAmn9EALw_wcB&gclsrc=aw.ds&BT_TX=1&ProspectID=22520D407F7147B1A6470981B0B9EF1B',
      'Logo': 'assets/logos/citibank.png',
      'Bank': 'Citi Bank',
      'Account': 'Regular Checking',
      'APY': '0%',
      'Min Opening Balance': '\$0',
      'Bonus Offer': '\$325',
      'Monthly Maintenance Fee': '\$15',
      'Fee Waiver Options': {
        'Direct Deposit': '\$250',
        'Daily Balance': null,
        'Student': null,
        'Transaction Minimum': null,
        'Military': false,
        'Other': true
      },
      'Overdraft Fee': '\$0',
      'ATM Fees': {
        'Out-of-Network': '\$2.50',
        'International': '\$2.50',
      },
      'Foreign Transaction Fee': '3%',
      'Tiered Relationship Program':
          'https://www.citi.com/banking/compare-bank-accounts',
    },
  ],
  'Savings, CDs, & Money Market': [
    {
      'URL': 'https://www.bankofamerica.com/deposits/savings/savings-accounts/',
      'Logo': 'assets/logos/bankofamerica.png',
      'Bank': 'Bank of America',
      'Account': 'Advantage Savings',
      'APY': '0.01%',
      'Min Opening Balance': '\$100',
      'Bonus Offer': '\$0',
      'Monthly Maintenance Fee': '\$8',
      'Fee Waiver Options': {
        'Daily Balance': '\$500',
        'Age': 'Under 25',
        'Linked Account': true,
        'Military': true,
        'Other': true
      },
      'Overdraft Fee': '\$0',
      'Tiered Relationship Program':
          'https://promotions.bankofamerica.com/preferredrewards/en',
    },
    {
      'URL': 'https://personal.chase.com/personal/savings',
      'Logo': 'assets/logos/chase.png',
      'Bank': 'Chase',
      'Account': 'Savings',
      'APY': '0.01%',
      'Min Opening Balance': '\$0',
      'Bonus Offer': '\$0',
      'Monthly Maintenance Fee': '\$5',
      'Fee Waiver Options': {
        'Daily Balance': '\$300',
        'Age': 'Under 18',
        'Linked Account': true,
        'Military': true,
        'Other': true
      },
      'Overdraft Fee': '\$34',
      'Tiered Relationship Program': null
    },
    {
      'URL':
          'https://www.capitalone.com/bank/savings-accounts/online-performance-savings-account/',
      'Logo': 'assets/logos/capitalone.png',
      'Bank': 'Capital One',
      'Account': '360 Performance Savings',
      'APY': '3.60%',
      'Min Opening Balance': '\$0',
      'Bonus Offer': '\$0',
      'Monthly Maintenance Fee': '\$0',
      'Fee Waiver Options': {
        'Daily Balance': null,
        'Age': null,
        'Linked Account': false,
        'Military': false,
        'Other': false
      },
      'Overdraft Fee': '\$0',
      'Tiered Relationship Program': null
    },
    {
      'URL': 'https://www.ally.com/bank/online-savings-account/',
      'Logo': 'assets/logos/allybank.png',
      'Bank': 'Ally Bank',
      'Account': 'Online Savings',
      'APY': '3.60%',
      'Min Opening Balance': '\$0',
      'Bonus Offer': '\$0',
      'Monthly Maintenance Fee': '\$0',
      'Fee Waiver Options': {
        'Daily Balance': null,
        'Age': null,
        'Linked Account': false,
        'Military': false,
        'Other': false
      },
      'Overdraft Fee': '\$0',
      'Tiered Relationship Program':
          'https://www.ally.com/bank/online-savings-account/'
    },
  ],
  'Credit Cards': [
    {
      'URL':
          'https://www.americanexpress.com/us/credit-cards/card/blue-cash-preferred/',
      'Logo': 'assets/logos/amex.png',
      'Bank': 'Amex',
      'Account': 'Blue Cash Everyday',
      'Bonus Offer': '\$250 Statement Credit',
      'Annual Fee': '\$0 Intro, then \$95',
      'Intro Purchases APR': '0% for 12 month',
      'Intro Balance Transfers APR': '0% for 12 months',
      'Purchases APR': '20.24% - 29.24%',
      'Balance Transfers APR': '20.24% - 29.24%',
      'Cash Advances APR': '29.49%',
      'Program': 'Cash Back',
      'Rewards': {
        '6%': 'Supermarkets & Streaming Services',
        '3%': 'Gas Stations & Transit',
        '1%': 'All Other Purchases',
      },
      'Foreign Transaction Fee': '2.7%',
      'Cash Advance Fee': '\$10 minimum or 5%',
      'Balance Transfer Fee': '\$5 minimum or 3%',
    },
    {
      'URL':
          'https://creditcards.chase.com/rewards-credit-cards/sapphire/preferred',
      'Logo': 'assets/logos/chase.png',
      'Bank': 'Chase',
      'Account': 'Sapphire Preferred',
      'Bonus Offer': '100,000 Points',
      'Annual Fee': '\$95',
      'Intro Purchases APR': null,
      'Intro Balance Transfers APR': null,
      'Purchases APR': '19.99% - 28.24%',
      'Balance Transfers APR': '19.99% - 28.24%',
      'Cash Advances APR': '29.24%',
      'Program': 'Points per \$1 spent',
      'Rewards': {
        '5x': 'Chase Travel',
        '3x': 'Dining, Online Grocery, & Streaming',
        '2x': 'Travel',
        '1x': 'All Other Purchases',
      },
      'Foreign Transaction Fee': '0%',
      'Cash Advance Fee': '\$5 minimum or 5%',
      'Balance Transfer Fee': '\$5 minimum or 5%',
    },
    {
      'URL':
          'https://www.discover.com/credit-cards/cash-back/it-card.html?ICMPGN=ALL_CC_CB_CARD',
      'Logo': 'assets/logos/discover.png',
      'Bank': 'Discover',
      'Account': 'Cashback',
      'Bonus Offer': '\$0',
      'Annual Fee': '\$0',
      'Intro Purchases APR': '0% for 15 month',
      'Intro Balance Transfers APR': '0% for 15 months',
      'Purchases APR': '18.24% - 27.24%',
      'Balance Transfers APR': '18.24% - 27.24%',
      'Cash Advances APR': '29.24%',
      'Program': 'Cash Back',
      'Rewards': {
        '5%': 'Groceries (Category Rotates Quarterly)',
        '1%': 'All Other Purchases',
      },
      'Foreign Transaction Fee': '0%',
      "Cash Advance Fee": '\$10 minimum or 5%',
      "Balance Transfer Fee": "3% intro, then 5%"
    },
    {
      'URL':
          'https://www.citi.com/usc/LPACA/Citi/Cards/DoubleCash/ps_A/index.html?cmp=knc|acquire|2006|CARDS|Google|BR&targetid=kwd-98337425605&gbraid=0AAAAADaf8I_T4omaQTqTFJNRevDWAe2Cm&gclid=Cj0KCQjwzrzABhD8ARIsANlSWNMKqCP2uPOb3J8XFcXM7tYzHzHF0t92RJTDPk4YcqA0ueUnI3IXppAaAhFPEALw_wcB&gclsrc=aw.ds&ProspectID=PHoasICZWMdop9fv9wJyopmrFs3Ers7a',
      'Logo': 'assets/logos/citibank.png',
      'Bank': 'Citi Bank',
      'Account': 'Double Cash',
      'Bonus Offer': '\$200',
      'Annual Fee': '\$0',
      'Intro Purchases APR': '0% for 18 month',
      'Intro Balance Transfers APR': '0% for 18 months',
      'Purchases APR': '18.24% - 27.24%',
      'Balance Transfers APR': '18.24% - 27.24%',
      'Cash Advances APR': '29.24%',
      'Program': 'Cash Back',
      'Rewards': {
        '2%': '1% on all purchases & 1% as you pay',
      },
      'Foreign Transaction Fee': '0%',
      "Cash Advance Fee": '\$10 minimum or 5%',
      "Balance Transfer Fee": "3% intro, then 5%"
    },
  ],
  'Auto Loans': [
    {
      'URL': 'https://www.bankofamerica.com/auto-loans/',
      'Logo': 'assets/logos/bankofamerica.png',
      'Bank': 'Bank of America',
      'Account': 'New Car',
      'Seller': 'Dealership',
      'APR': 'As low as 5.59%',
      'Month Term Lengths': '48, 60, 72',
      'Prepayment Penalty': false,
    },
    {
      'URL': 'https://www.bankofamerica.com/auto-loans/',
      'Logo': 'assets/logos/bankofamerica.png',
      'Bank': 'Bank of America',
      'Account': 'Used Car',
      'Seller': 'Dealership',
      'APR': 'As low as 5.79%',
      'Month Term Lengths': '48, 60, 72',
      'Prepayment Penalty': false,
    },
    {
      'URL': 'https://www.bankofamerica.com/auto-loans/',
      'Logo': 'assets/logos/bankofamerica.png',
      'Bank': 'Bank of America',
      'Account': 'Lease Buyout',
      'Seller': null,
      'APR': 'As low as 6.19%',
      'Month Term Lengths': '48, 60, 72',
      'Prepayment Penalty': false,
    },
    {
      'URL': 'https://www.bankofamerica.com/auto-loans/',
      'Logo': 'assets/logos/bankofamerica.png',
      'Bank': 'Bank of America',
      'Account': 'Refinance',
      'Seller': null,
      'APR': 'As low as 6.19%',
      'Month Term Lengths': '48, 60, 72',
      'Prepayment Penalty': false,
    },
    {
      'URL': 'https://autofinance.chase.com/auto-finance/auto-loans',
      'Logo': 'assets/logos/chase.png',
      'Bank': 'Chase',
      'Account': 'New Car',
      'Seller': 'Dealership',
      'APR': 'As low as 5.84%',
      'Month Term Lengths': '48, 60, 72',
      'Prepayment Penalty': false,
    },
    {
      'URL': 'https://autofinance.chase.com/auto-finance/auto-loans',
      'Logo': 'assets/logos/chase.png',
      'Bank': 'Chase',
      'Account': 'Used Car',
      'Seller': 'Dealership',
      'APR': 'As low as 6.29%',
      'Month Term Lengths': '48, 60, 72',
      'Prepayment Penalty': false,
    },
    {
      'URL': 'https://www.usaa.com/banking/loans/auto/',
      'Logo': 'assets/logos/usaa.png',
      'Bank': 'USAA',
      'Account': 'New Car',
      'Seller': 'Dealership',
      'APR': 'As low as 5.35%',
      'Month Term Lengths': '36, 48, 60, 66, 72, 75, 78, 84',
      'Prepayment Penalty': false,
    },
    {
      'URL': 'https://www.usaa.com/banking/loans/auto/',
      'Logo': 'assets/logos/usaa.png',
      'Bank': 'USAA',
      'Account': 'Used Car',
      'Seller': 'Dealership',
      'APR': 'As low as 5.35%',
      'Month Term Lengths': '36, 48, 60, 66, 72, 75, 78, 84',
      'Prepayment Penalty': false,
    },
    {
      'URL': 'https://www.usaa.com/banking/loans/auto/',
      'Logo': 'assets/logos/usaa.png',
      'Bank': 'USAA',
      'Account': 'Used Car',
      'Seller': 'Private Party',
      'APR': 'As low as 6.60%',
      'Month Term Lengths': '36, 48, 60, 66, 72, 75, 78, 84',
      'Prepayment Penalty': false,
    },
    {
      'URL': 'https://www.usaa.com/banking/loans/auto/',
      'Logo': 'assets/logos/usaa.png',
      'Bank': 'USAA',
      'Account': 'Refinance',
      'Seller': null,
      'APR': 'As low as 5.35%',
      'Month Term Lengths': '36, 48, 60, 66, 72, 75, 78, 84',
      'Prepayment Penalty': false,
    },
    {
      'URL':
          'https://www.pnc.com/en/personal-banking/borrowing/auto-loans/browse-auto-loans.html',
      'Logo': 'assets/logos/pncbank.png',
      'Bank': 'PNC Bank',
      'Account': 'New Car',
      'Seller': 'Dealership',
      'APR': 'As low as 5.64%',
      'Month Term Lengths': '12, 24, 36, 48, 60, 72, 84',
      'Prepayment Penalty': false,
    },
    {
      'URL':
          'https://www.pnc.com/en/personal-banking/borrowing/auto-loans/browse-auto-loans.html',
      'Logo': 'assets/logos/pncbank.png',
      'Bank': 'PNC Bank',
      'Account': 'Used Car',
      'Seller': 'Dealership',
      'APR': 'As low as 5.64%',
      'Month Term Lengths': '12, 24, 36, 48, 60, 72, 84',
      'Prepayment Penalty': false,
    },
    {
      'URL':
          'https://www.pnc.com/en/personal-banking/borrowing/auto-loans/browse-auto-loans.html',
      'Logo': 'assets/logos/pncbank.png',
      'Bank': 'PNC Bank',
      'Account': 'Used Car',
      'Seller': 'Private Party',
      'APR': 'As low as 8.34%',
      'Month Term Lengths': '12, 24, 36, 48, 60, 72, 84',
      'Prepayment Penalty': false,
    },
    {
      'URL':
          'https://www.pnc.com/en/personal-banking/borrowing/auto-loans/browse-auto-loans.html',
      'Logo': 'assets/logos/pncbank.png',
      'Bank': 'PNC Bank',
      'Account': 'Refinance',
      'Seller': null,
      'APR': 'As low as 6.09%',
      'Month Term Lengths': '12, 24, 36, 48, 60, 72, 84',
      'Prepayment Penalty': false,
    },
  ],
  'Investments': [
    {
      'URL': 'https://www.fidelity.com/trading/the-fidelity-account',
      'Logo': 'assets/logos/fidelity.png',
      'Bank': 'Fidelity',
      'Account': 'Brokerage Account',
      'Trade Commission': '\$0',
      'Min Opening Balance': '\$0',
      'Asset Classes': '10',
      'Stocks': true,
      'Bonds': true,
      'Mutual Funds': true,
      'ETFs': true,
      'Options': true,
      'CDs': true,
      'Crypto': true,
      'Precious Metals': true,
      'International Markets': true,
      'Money Market Funds': false,
      'Fixed Income': false,
      'Index Funds': false,
      'Futures': false,
      'Forex': false,
    },
    {
      'URL': 'https://investor.vanguard.com/accounts-plans/brokerage-accounts',
      'Logo': 'assets/logos/vanguard.png',
      'Bank': 'Vanguard',
      'Account': 'Brokerage Account',
      'Trade Commission': '\$0',
      'Min Opening Balance': '\$0',
      'Asset Classes': '5',
      'Stocks': true,
      'Bonds': true,
      'Mutual Funds': true,
      'ETFs': true,
      'Options': false,
      'CDs': true,
      'Crypto': false,
      'Precious Metals': false,
      'International Markets': false,
      'Money Market Funds': false,
      'Fixed Income': false,
      'Index Funds': false,
      'Futures': false,
      'Forex': false,
    },
    {
      'URL': 'https://www.schwab.com/brokerage',
      'Logo': 'assets/logos/charlesschwab.png',
      'Bank': 'Charles Schwab',
      'Account': 'Brokerage Account',
      'Trade Commission': '\$0',
      'Min Opening Balance': '\$0',
      'Asset Classes': '12',
      'Stocks': true,
      'Bonds': true,
      'Mutual Funds': true,
      'ETFs': true,
      'Options': true,
      'CDs': false,
      'Crypto': true,
      'Precious Metals': false,
      'International Markets': true,
      'Money Market Funds': true,
      'Fixed Income': true,
      'Index Funds': true,
      'Futures': true,
      'Forex': true,
    }
  ],
};

// Function to return shuffled categories
Map<String, List<Map<String, dynamic>>> getShuffledCategories() {
  final random = Random();
  final shuffledCategories =
      Map<String, List<Map<String, dynamic>>>.from(_categories);

  shuffledCategories.forEach((key, value) {
    value.shuffle(random);
  });

  return shuffledCategories;
}

/// Fetches live marketplace data from Firestore via [MarketplaceRepository],
/// falling back to [getShuffledCategories] if Firestore is unavailable.
///
/// Import this from pages that need dynamic data:
/// ```dart
/// import 'categories_data.dart';
/// // ...
/// final data = await fetchFirestoreCategories();
/// ```
Future<Map<String, List<Map<String, dynamic>>>> fetchFirestoreCategories() {
  // Lazy import avoids a circular-dependency if repository imports this file.
  return MarketplaceRepository.fetchCategories();
}
