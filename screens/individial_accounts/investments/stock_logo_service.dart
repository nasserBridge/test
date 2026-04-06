import 'dart:convert';
import 'package:http/http.dart' as http;

class StockLogoService {
  // In-memory cache to avoid duplicate API calls
  static final Map<String, String> _logoCache = {};

  // Replace with your actual Finnhub API key
  static const String _apiKey = 'd1iq7f1r01qhbuvrk52gd1iq7f1r01qhbuvrk530';

  /// Returns a logo URL for a given ticker symbol (e.g., 'AAPL').
  /// Uses Finnhub's `profile2` endpoint and caches the result.
  static Future<String?> getLogoUrl(String? ticker) async {
    if (ticker == null || ticker.trim().isEmpty) return null;

    // Return from cache if already fetched
    if (_logoCache.containsKey(ticker)) {
      return _logoCache[ticker];
    }

    final url =
        'https://finnhub.io/api/v1/stock/profile2?symbol=$ticker&token=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract logo directly from the response
        final logo = data['logo'];
        if (logo != null && logo.toString().isNotEmpty) {
          _logoCache[ticker] = logo;
          return logo;
        }
      }
    } catch (e) {
      // Silently ignore logo fetch errors
    }

    return null;
  }
}
