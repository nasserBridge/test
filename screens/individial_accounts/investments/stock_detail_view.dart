import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/investments/holdings_extension_display.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/investments/holdings_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/investments/stock_logo_service.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/white_container.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StockDetailView extends StatelessWidget {
  final HoldingsModel holding;

  const StockDetailView({
    super.key,
    required this.holding,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final numberFormat = NumberFormat('#,##0.##');
    final percentFormat = NumberFormat('+0.00;-0.00');

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 245, 242),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 231, 245, 242),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          holding.tickerSymbol ?? 'Stock Details',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Scale.x(20)),

            // Header section with stock info
            _buildHeaderSection(currencyFormat, numberFormat, percentFormat),

            SizedBox(height: Scale.x(20)),

            // Position details
            _buildPositionDetails(currencyFormat, numberFormat),

            SizedBox(height: Scale.x(20)),

            // Company info
            if (holding.industry != null || holding.sector != null)
              _buildCompanyInfo(),

            SizedBox(height: Scale.x(30)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    NumberFormat currencyFormat,
    NumberFormat numberFormat,
    NumberFormat percentFormat,
  ) {
    return WhiteContainer(
      margin: EdgeInsets.only(left: Scale.x(30), right: Scale.x(30)),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Logo and name
          FutureBuilder<String?>(
            future: holding.tickerSymbol != null
                ? StockLogoService.getLogoUrl(holding.tickerSymbol!)
                : null,
            builder: (context, snapshot) {
              final logoUrl = snapshot.data;
              return Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Scale.x(12)),
                    ),
                    child: logoUrl != null && logoUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(Scale.x(12)),
                            child: Image.network(
                              logoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildFallbackLogo(),
                            ),
                          )
                        : _buildFallbackLogo(),
                  ),
                  SizedBox(width: Scale.x(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          holding.name ?? 'Unknown',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: Scale.x(18),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (holding.tickerSymbol != null)
                          Text(
                            holding.tickerSymbol!,
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.5),
                              fontSize: Scale.x(14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: Scale.x(24)),
          Divider(height: Scale.x(1)),
          SizedBox(height: Scale.x(24)),

          // Market value
          if (holding.marketValue != null)
            Column(
              children: [
                Text(
                  'Current Value',
                  style: TextStyle(
                    color: Color.fromARGB(239, 100, 100, 100),
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    fontSize: FontSizes.statements,
                  ),
                ),
                SizedBox(height: Scale.x(8)),
                Text(
                  currencyFormat.format(holding.marketValue!),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Scale.x(12)),
                if (holding.totalGainLoss != null &&
                    holding.percentageGainLoss != null)
                  _buildGainLossIndicator(
                    holding.totalGainLoss!,
                    holding.percentageGainLoss!,
                    currencyFormat,
                    percentFormat,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Center(
      child: Text(
        holding.tickerSymbol?.isNotEmpty == true
            ? holding.tickerSymbol![0]
            : '?',
        style: TextStyle(
          fontSize: Scale.x(24),
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildGainLossIndicator(
    double gainLoss,
    double percentage,
    NumberFormat currencyFormat,
    NumberFormat percentFormat,
  ) {
    final isPositive = gainLoss >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: Scale.x(16),
          ),
          SizedBox(width: Scale.x(4)),
          Text(
            '${currencyFormat.format(gainLoss.abs())} (${percentFormat.format(percentage)}%)',
            style: TextStyle(
              color: color,
              fontSize: Scale.x(16),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionDetails(
    NumberFormat currencyFormat,
    NumberFormat numberFormat,
  ) {
    return WhiteContainer(
      margin: EdgeInsets.only(left: Scale.x(30), right: Scale.x(30)),
      padding: EdgeInsets.fromLTRB(
          Scale.x(10), Scale.x(13), Scale.x(10), Scale.x(13)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Scale.x(10)),
            child: Text(
              'Position Details',
              style: TextStyle(
                color: Color.fromARGB(239, 100, 100, 100),
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                fontSize: FontSizes.statements,
              ),
            ),
          ),
          SizedBox(height: Scale.x(10)),
          _buildDetailRow(
            'Shares',
            holding.quantity != null
                ? numberFormat.format(holding.quantity!)
                : 'N/A',
          ),
          _buildDivider(),
          _buildDetailRow(
            'Average Cost',
            holding.averageCostPerShare != null
                ? currencyFormat.format(holding.averageCostPerShare!)
                : 'N/A',
          ),
          _buildDivider(),
          _buildDetailRow(
            'Current Price',
            holding.closePrice != null
                ? currencyFormat.format(holding.closePrice!)
                : 'N/A',
          ),
          _buildDivider(),
          _buildDetailRow(
            'Total Cost',
            holding.totalCostBasis != null
                ? currencyFormat.format(holding.totalCostBasis!)
                : 'N/A',
          ),
          _buildDivider(),
          _buildDetailRow(
            'Market Value',
            holding.marketValue != null
                ? currencyFormat.format(holding.marketValue!)
                : 'N/A',
          ),
          if (holding.totalGainLoss != null) ...[
            _buildDivider(),
            _buildDetailRow(
              'Total Gain/Loss',
              holding.totalGainLoss != null
                  ? currencyFormat.format(holding.totalGainLoss!)
                  : 'N/A',
              valueColor: holding.isGain ? Colors.green : Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return WhiteContainer(
      margin: EdgeInsets.only(left: Scale.x(30), right: Scale.x(30)),
      padding: EdgeInsets.fromLTRB(
          Scale.x(10), Scale.x(13), Scale.x(10), Scale.x(13)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Scale.x(10)),
            child: Text(
              'Company Information',
              style: TextStyle(
                color: Color.fromARGB(239, 100, 100, 100),
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                fontSize: FontSizes.statements,
              ),
            ),
          ),
          SizedBox(height: Scale.x(10)),
          if (holding.sector != null) ...[
            _buildDetailRow('Sector', holding.sector!),
            if (holding.industry != null) _buildDivider(),
          ],
          if (holding.industry != null)
            _buildDetailRow('Industry', holding.industry!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: Scale.x(10), vertical: Scale.x(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Scale.x(15),
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: Scale.x(15),
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: Scale.x(1),
      thickness: Scale.x(0.5),
      indent: Scale.x(10),
      endIndent: Scale.x(10),
    );
  }
}
