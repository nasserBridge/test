import 'package:bridgeapp/src/utils/scale.dart';

class FontSizes {
  //Used in the account_view page
  static double titleW = Scale.x(24); // W in Welcome, Font: Raleway, Weight:600
  static double titleELCOME =
      Scale.x(20); // 'elcome' in Welcome, Font: Raleway, Weight:600
  static double titleName = Scale.x(35); // 'Alex', Font: Raleway, Weight:600
  static double dashboardText = Scale.x(13); // Net Worth, Assets, Debt
  static double dashboardAmount = Scale.x(17);
  static double bigBanner =
      Scale.x(21); // Account Summary, Font: PT Sans, W: Bold
  static double accountGroup =
      Scale.x(15); //'Checkings, Savings, etc', Font: Open Sans, W: NA
  static double combinedBalance =
      Scale.x(17); //$432.44, Font: Open Sans, W: Bold

  //Used in the dropdown
  static double dropdownName = Scale.x(
      16); // Chase 3723: Platinum 2% Interest Checking, Font:(device native font, likely San Francisco for ios), W: NA
  static double dropdownBalance =
      Scale.x(19); // $437.11, Font: device native font, w:bold
  static double dropdownViewAllT = Scale.x(17); // NA
  static double viewButton =
      Scale.x(15); ////View button, Font: device native font, w: NA

  // Account View Header Bar
  static double tHeader = Scale.x(20); //Chase, Font: Raleway, W: na

  //Used when view account specific information
  static double accountName = Scale.x(
      22); // Platinum 2% Interest Checking 3729, Font: Raleway, Weight:600
  static double totalBalance = Scale.x(30); // $323.35, Font: PT Sans, w: 600
  static double balancetext = Scale.x(16); // Balance, F: Raleway, W: NA
  static double accrouteNumber = Scale.x(15); // NA

  // Statements wigit
  static double statements =
      Scale.x(15); // Statements, F: Open Sans, w: 600, letter spaceing 1.5
  static double statementMonth = Scale.x(14); // May, F: Open Sans, W: Na
  static double viewStatements =
      Scale.x(11); // View Button. F:device native font, W:NA,

  // Transaction text
  static double recentTransactions = Scale.x(
      15); // Recent Transactions, F: Open Sans, w: 600, letter spaceing 1.5
  static double transDate = Scale.x(14); // 10/05/2024, F: Open Sans, W: Na
  static double transInfo =
      Scale.x(17); // Uber, F: Open Sans, W: Na, Has a slight shadow effect
  static double transType =
      Scale.x(17); // Online, F: Open Sans, W: Na, Shadow: True
  static double transAmount = Scale.x(18); // +/-$12.99 F: Open Sans, W: Bold
  static double transBalance =
      Scale.x(14); //+/-432.33 F: Opens Sans, W: NA, Shadow True

  //navbar
  static double navText = Scale.x(
      13); // Navigation bar text (accounts, transfer, etc) Font: Raleway, Slight Shadow: true, w: NA

  //profile
  static double profileTitle = Scale.x(25);
  static double smallTitle = Scale.x(16);
  static double profileInfo = Scale.x(18);
  static double profilePhone = Scale.x(19);
  static double profileEdit = Scale.x(13);
  static double profileDelete = Scale.x(14);

  //Onboarding Process
  static double stepTitle = Scale.x(18);
  static double stepStatus = Scale.x(16);

  //Survey Pages
  static double question = Scale.x(15);
}
