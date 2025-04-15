import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  static const String _premiumKey = 'is_premium';
  static const String _trailerViewsKey = 'daily_trailer_views';
  static const String _lastResetDateKey = 'last_reset_date';
  
  static const int maxFreeTrailerViews = 3;
  
  // Product IDs for in-app purchases
  static const String removeAdsId = 'remove_ads';
  static const String premiumMonthlyId = 'premium_monthly';
  static const String premiumYearlyId = 'premium_yearly';
  static const String proMonthlyId = 'pro_monthly';
  static const String proYearlyId = 'pro_yearly';

  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static final Set<String> _productIds = {
    removeAdsId,
    premiumMonthlyId,
    premiumYearlyId,
    proMonthlyId,
    proYearlyId,
  };

  static Future<void> initialize() async {
    if (await _inAppPurchase.isAvailable()) {
      await _loadProducts();
    }
    await _resetDailyViewsIfNeeded();
  }

  static Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(_productIds);
      if (response.notFoundIDs.isNotEmpty) {
        print('Products not found: ${response.notFoundIDs}');
      }
      // Store products for later use
      products = response.productDetails;
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  static List<ProductDetails> products = [];

  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumKey) ?? false;
  }

  static Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
  }

  static Future<int> getRemainingTrailerViews() async {
    if (await isPremium()) return -1; // Unlimited for premium users
    
    final prefs = await SharedPreferences.getInstance();
    final views = prefs.getInt(_trailerViewsKey) ?? 0;
    return maxFreeTrailerViews - views;
  }

  static Future<bool> canWatchTrailer() async {
    if (await isPremium()) return true;
    return await getRemainingTrailerViews() > 0;
  }

  static Future<void> incrementTrailerViews() async {
    if (await isPremium()) return;
    
    final prefs = await SharedPreferences.getInstance();
    final views = prefs.getInt(_trailerViewsKey) ?? 0;
    await prefs.setInt(_trailerViewsKey, views + 1);
  }

  static Future<void> _resetDailyViewsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDate = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt(_lastResetDateKey) ?? 0
    );
    
    final now = DateTime.now();
    if (lastResetDate.day != now.day || lastResetDate.month != now.month || lastResetDate.year != now.year) {
      await prefs.setInt(_trailerViewsKey, 0);
      await prefs.setInt(_lastResetDateKey, now.millisecondsSinceEpoch);
    }
  }

  static Future<void> purchaseProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    
    if (product.id == removeAdsId) {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    }
  }

  static void listenToPurchaseUpdates(void Function(List<PurchaseDetails>) onPurchaseUpdate) {
    _inAppPurchase.purchaseStream.listen((purchases) {
      _handlePurchaseUpdates(purchases, onPurchaseUpdate);
    });
  }

  static void _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
    void Function(List<PurchaseDetails>) onPurchaseUpdate,
  ) async {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await setPremium(true);
      }
    }
    onPurchaseUpdate(purchases);
  }
} 