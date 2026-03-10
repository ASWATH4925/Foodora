import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiggy_ui/models/restaurant_detail.dart';
import 'package:swiggy_ui/models/spotlight_best_top_food.dart';
import 'package:swiggy_ui/models/order_provider.dart';
import 'package:swiggy_ui/views/mobile/foodora/restaurants/restaurant_detail_screen.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final List<_FoodSuggestion>? suggestions;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.suggestions,
  }) : time = DateTime.now();
}

class _FoodSuggestion {
  final String restaurantName;
  final String cuisine;
  final String rating;
  final String priceForTwo;
  final String deliveryTime;
  final String image;
  final SpotlightBestTopFood? spotlightData;
  final List<String> matchedDishes;

  _FoodSuggestion({
    required this.restaurantName,
    required this.cuisine,
    required this.rating,
    required this.priceForTwo,
    required this.deliveryTime,
    required this.image,
    this.spotlightData,
    this.matchedDishes = const [],
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final List<String> _chatHistory = [];

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Welcome message with personalization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final recentFoods = orderProvider.recentFoodNames;
      final frequentRestaurants = orderProvider.frequentRestaurants;

      String welcome = 'Hey there! 👋 I\'m your Foodora AI assistant!\n\n'
          'I can help you find the perfect food based on your preferences. Try asking me:\n\n'
          '🍽️ "Find me South Indian food"\n'
          '💰 "Something under ₹100"\n'
          '🥬 "Veg options"\n'
          '🍖 "Non-veg restaurants"\n'
          '⭐ "Best rated restaurants"\n'
          '🔥 "Spicy food"\n'
          '🍕 "I want pizza"\n'
          '📜 "My order history"\n'
          '🔮 "Suggest something for me"\n'
          '📊 "Tell me about biryani" (nutrition info)';

      if (recentFoods.isNotEmpty) {
        welcome += '\n\n💡 Based on your history, you might enjoy: ${recentFoods.take(3).join(", ")}';
      }
      if (frequentRestaurants.isNotEmpty) {
        welcome += '\n🏪 Your favourite spots: ${frequentRestaurants.join(", ")}';
      }

      _addBotMessage(welcome);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addBotMessage(String text, {List<_FoodSuggestion>? suggestions}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        suggestions: suggestions,
      ));
    });
    _scrollToBottom();
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _chatHistory.add(text);
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    Timer(const Duration(milliseconds: 800), () {
      final response = _processQuery(text.toLowerCase());
      setState(() => _isTyping = false);
      _addBotMessage(response.message, suggestions: response.suggestions);
    });
  }

  _BotResponse _processQuery(String query) {
    final allRestaurants = [
      ...SpotlightBestTopFood.getPopularAllRestaurants(),
      ..._flattenLists(SpotlightBestTopFood.getSpotlightRestaurants()),
      ..._flattenLists(SpotlightBestTopFood.getBestRestaurants()),
      ..._flattenLists(SpotlightBestTopFood.getTopRestaurants()),
    ];

    final seen = <String>{};
    final uniqueRestaurants = allRestaurants.where((r) {
      if (seen.contains(r.name)) return false;
      seen.add(r.name);
      return true;
    }).toList();

    List<_FoodSuggestion> suggestions = [];
    String message = '';

    // Greetings
    if (_isGreeting(query)) {
      return _BotResponse(
        message: 'Hello! 😊 What kind of food are you craving today? Tell me about your cuisine preference, budget, or dietary needs!',
      );
    }

    // Thank you
    if (query.contains('thank') || query.contains('thanks')) {
      return _BotResponse(
        message: 'You\'re welcome! 😊 Enjoy your meal! Feel free to ask me anything else.',
      );
    }

    // Dish info / nutrition query
    if (_hasDishInfoQuery(query)) {
      return _getDishInfo(query);
    }

    // Order history query
    if (_hasHistoryQuery(query)) {
      return _getOrderHistory();
    }

    // Prediction / suggestion query
    if (_hasPredictionQuery(query)) {
      return _getPrediction(uniqueRestaurants);
    }

    // Budget-based search
    if (_hasBudgetQuery(query)) {
      final budget = _extractBudget(query);
      if (budget != null) {
        suggestions = _filterByBudget(uniqueRestaurants, budget);
        if (suggestions.isNotEmpty) {
          message = '💰 Here are restaurants where you can eat for two under ₹$budget:';
        } else {
          message = 'I couldn\'t find restaurants under ₹$budget. Try a slightly higher budget?';
        }
      }
    }

    // Dietary search (veg/non-veg) - MUST come before cuisine to properly handle "non veg"
    if (suggestions.isEmpty && _hasDietaryQuery(query)) {
      final isNonVeg = query.contains('non') || query.contains('nonveg') ||
          query.contains('non-veg') || query.contains('chicken') ||
          query.contains('mutton') || query.contains('fish') ||
          query.contains('meat') || query.contains('egg');
      final isVeg = !isNonVeg && (query.contains('veg') || query.contains('vegetarian'));

      if (isNonVeg) {
        suggestions = _filterByDiet(uniqueRestaurants, false);
        message = '🍖 Here are the best non-veg restaurants for you:';
      } else if (isVeg) {
        suggestions = _filterByDiet(uniqueRestaurants, true);
        message = '🥬 Here are great pure vegetarian options:';
      }
    }

    // Cuisine-based search
    if (suggestions.isEmpty && _hasCuisineQuery(query)) {
      final cuisine = _extractCuisine(query);
      if (cuisine != null) {
        suggestions = _filterByCuisine(uniqueRestaurants, cuisine);
        if (suggestions.isNotEmpty) {
          message = '🍽️ Here are the best $cuisine restaurants for you:';
        } else {
          message = 'No $cuisine restaurants found. Try another cuisine?';
        }
      }
    }

    // Rating-based search
    if (suggestions.isEmpty && _hasRatingQuery(query)) {
      suggestions = _filterByRating(uniqueRestaurants);
      message = '⭐ Here are the highest-rated restaurants:';
    }

    // Quick delivery
    if (suggestions.isEmpty && _hasQuickDeliveryQuery(query)) {
      suggestions = _filterByDeliveryTime(uniqueRestaurants);
      message = '⚡ Here are restaurants with the fastest delivery:';
    }

    // Spicy food search
    if (suggestions.isEmpty && _hasSpicyQuery(query)) {
      suggestions = _filterBySpicy(uniqueRestaurants);
      message = '🌶️ Here are restaurants known for spicy food:';
    }

    // Specific food search
    if (suggestions.isEmpty && _hasSpecificFood(query)) {
      final result = _searchSpecificFood(uniqueRestaurants, query);
      suggestions = result.suggestions;
      if (suggestions.isNotEmpty) {
        message = '🔍 Found these options matching your search:';
      }
    }

    // General search
    if (suggestions.isEmpty) {
      suggestions = _generalSearch(uniqueRestaurants, query);
      if (suggestions.isNotEmpty) {
        message = '🍽️ Here\'s what I found for you:';
      } else {
        // Provide smart suggestion based on history
        final prediction = _getPrediction(uniqueRestaurants);
        if (prediction.suggestions.isNotEmpty) {
          return _BotResponse(
            message: 'I couldn\'t find an exact match for "$query" 🤔\n\n'
                'But based on your order history, you might enjoy these:',
            suggestions: prediction.suggestions,
          );
        }
        message = 'I couldn\'t find an exact match for "$query" 🤔\n\n'
            'Try searching by:\n'
            '• Cuisine: "South Indian", "North Indian", "Pizza"\n'
            '• Budget: "under 200", "cheap"\n'
            '• Diet: "pure veg", "non-veg", "chicken"\n'
            '• Speed: "quick delivery", "fast"\n'
            '• Rating: "best rated", "top restaurants"\n'
            '• History: "my orders", "suggest something"';
      }
    }

    return _BotResponse(message: message, suggestions: suggestions);
  }

  // ── History and Predictions ──

  bool _hasHistoryQuery(String q) =>
      q.contains('history') || q.contains('my order') || q.contains('past order') ||
      q.contains('previous order') || q.contains('ordered before');

  bool _hasPredictionQuery(String q) =>
      q.contains('suggest') || q.contains('recommend') || q.contains('predict') ||
      q.contains('what should') || q.contains('surprise') || q.contains('for me') ||
      q.contains('mood for');

  _BotResponse _getOrderHistory() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final orders = orderProvider.orders;

    if (orders.isEmpty) {
      return _BotResponse(
        message: '📭 You don\'t have any past orders yet. Start ordering to build your food history!',
      );
    }

    String history = '📜 Here are your recent orders:\n\n';
    for (int i = 0; i < orders.length && i < 5; i++) {
      final o = orders[i];
      final rated = o.isRated ? ' ⭐${o.rating.toStringAsFixed(1)}' : '';
      history += '${i + 1}. 🏪 ${o.restaurantName}$rated\n'
          '   ${o.itemsSummary}\n'
          '   ₹${o.totalAmount.toStringAsFixed(0)} • ${o.formattedDate}\n\n';
    }

    history += 'Say "suggest something for me" and I\'ll recommend based on your taste! 🎯';

    return _BotResponse(message: history);
  }

  _BotResponse _getPrediction(List<SpotlightBestTopFood> restaurants) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final recentFoods = orderProvider.recentFoodNames;
    final frequentRestaurants = orderProvider.frequentRestaurants;

    List<_FoodSuggestion> suggestions = [];

    // Step 1: Suggest from frequent restaurants
    for (final restName in frequentRestaurants) {
      for (final r in restaurants) {
        if (r.name.toLowerCase().contains(restName.toLowerCase()) ||
            restName.toLowerCase().contains(r.name.toLowerCase())) {
          suggestions.add(_toSuggestion(r, matchedDishes: ['Your favourite spot! 🌟']));
          break;
        }
      }
    }

    // Step 2: Search menus for similar foods to past orders
    for (final foodName in recentFoods) {
      if (suggestions.length >= 5) break;
      for (final r in restaurants) {
        if (suggestions.any((s) => s.restaurantName == r.name)) continue;
        final menus = RestaurantDetail.getMenusFor(r.name);
        for (final menuList in menus) {
          for (final dish in menuList) {
            if (dish.title.toLowerCase().contains(foodName.toLowerCase()) ||
                foodName.toLowerCase().contains(dish.title.toLowerCase().split(' ').first)) {
              suggestions.add(_toSuggestion(r,
                  matchedDishes: ['${dish.title} - ${dish.price} (similar to your $foodName)']));
              break;
            }
          }
          if (suggestions.any((s) => s.restaurantName == r.name)) break;
        }
      }
    }

    // Step 3: If no history, suggest top-rated
    if (suggestions.isEmpty) {
      suggestions = _filterByRating(restaurants);
      return _BotResponse(
        message: '🔮 You don\'t have much order history yet. Here are our top-rated picks to get started:',
        suggestions: suggestions,
      );
    }

    // Analyze user patterns for message
    String patternMsg = '🔮 Based on your taste profile:\n';
    if (frequentRestaurants.isNotEmpty) {
      patternMsg += '🏪 You love: ${frequentRestaurants.join(", ")}\n';
    }
    if (recentFoods.isNotEmpty) {
      patternMsg += '🍽️ You often order: ${recentFoods.take(3).join(", ")}\n';
    }
    patternMsg += '\nHere are my personalized recommendations:';

    return _BotResponse(message: patternMsg, suggestions: suggestions);
  }

  // ── Helpers ──

  List<SpotlightBestTopFood> _flattenLists(List<List<SpotlightBestTopFood>> lists) {
    return lists.expand((list) => list).toList();
  }

  bool _isGreeting(String q) =>
      q == 'hi' || q == 'hello' || q == 'hey' || q == 'yo' || q == 'hola';

  bool _hasBudgetQuery(String q) =>
      q.contains('under') || q.contains('below') || q.contains('cheap') ||
      q.contains('budget') || q.contains('affordable') ||
      (RegExp(r'\d+').hasMatch(q) && !_hasHistoryQuery(q));

  bool _hasCuisineQuery(String q) =>
      q.contains('south indian') || q.contains('north indian') ||
      q.contains('continental') || q.contains('pizza') || q.contains('biryani') ||
      q.contains('chinese') || q.contains('italian') || q.contains('street food') ||
      q.contains('bbq') || q.contains('chai') || q.contains('tea') ||
      q.contains('dosa') || q.contains('idli') || q.contains('idly') ||
      q.contains('parotta') || q.contains('paratha') || q.contains('burger');

  bool _hasDietaryQuery(String q) =>
      q.contains('veg') || q.contains('vegetarian') || q.contains('non-veg') ||
      q.contains('nonveg') || q.contains('non veg') || q.contains('chicken') ||
      q.contains('mutton') || q.contains('fish') || q.contains('meat') ||
      q.contains('egg') || q.contains('pure veg');

  bool _hasRatingQuery(String q) =>
      q.contains('best') || q.contains('top') || q.contains('rated') ||
      q.contains('popular') || q.contains('famous');

  bool _hasQuickDeliveryQuery(String q) =>
      q.contains('quick') || q.contains('fast') || q.contains('express') ||
      q.contains('hurry') || q.contains('urgent');

  bool _hasSpicyQuery(String q) =>
      q.contains('spicy') || q.contains('spice') || q.contains('hot') ||
      q.contains('masala');

  // ── Dish Info / Nutrition ──

  bool _hasDishInfoQuery(String q) =>
      q.contains('tell me about') || q.contains('info about') ||
      q.contains('nutrition') || q.contains('calories in') ||
      q.contains('calorie') || q.contains('protein in') ||
      q.contains('healthy') || q.contains('health benefit') ||
      q.contains('what is') || q.contains('describe') ||
      q.contains('details of') || q.contains('about the dish') ||
      q.contains('how healthy') || q.contains('is it good') ||
      q.contains('good for') || q.contains('nutrients');

  _BotResponse _getDishInfo(String query) {
    String? matchedKey;
    for (final key in _dishNutritionDb.keys) {
      if (query.contains(key)) {
        matchedKey = key;
        break;
      }
    }
    if (matchedKey == null) {
      for (final key in _dishNutritionDb.keys) {
        final words = key.split(' ');
        for (final word in words) {
          if (word.length > 3 && query.contains(word)) {
            matchedKey = key;
            break;
          }
        }
        if (matchedKey != null) break;
      }
    }

    if (matchedKey == null) {
      return _BotResponse(
        message: 'I don\'t have nutrition info for that dish yet.\n\n'
            'Try asking about these dishes:\n'
            '🍛 Biryani, Dosa, Idly, Paneer Butter Masala\n'
            '🍕 Pizza, Burger, Pasta, Noodles\n'
            '🥘 Chole Bhature, Pav Bhaji, Samosa\n'
            '☕ Filter Coffee, Masala Chai, Lassi\n'
            '🍰 Gulab Jamun, Ice Cream, Brownie\n\n'
            'Try: "Tell me about biryani" or "calories in dosa"',
      );
    }

    final info = _dishNutritionDb[matchedKey]!;
    final name = info['name'] as String;
    final emoji = info['emoji'] as String;
    final calories = info['calories'] as String;
    final protein = info['protein'] as String;
    final carbs = info['carbs'] as String;
    final fat = info['fat'] as String;
    final fiber = info['fiber'] as String;
    final bestTime = info['best_time'] as String;
    final benefits = info['benefits'] as List<String>;
    final tags = info['tags'] as List<String>;
    final description = info['description'] as String;
    final funFact = info['fun_fact'] as String;
    final servingSize = info['serving'] as String;

    String msg = '$emoji $name - Nutrition Guide\n'
        '━━━━━━━━━━━━━━━━━━━━\n\n'
        '$description\n\n'
        '📊 Nutritional Info (per $servingSize serving):\n'
        '🔥 Calories : $calories\n'
        '💪 Protein  : $protein\n'
        '🌾 Carbs    : $carbs\n'
        '🧈 Fat      : $fat\n'
        '🥬 Fiber    : $fiber\n\n'
        '⏰ Best Time to Eat:\n$bestTime\n\n'
        '✅ Health Benefits:\n';
    for (final b in benefits) {
      msg += '  • $b\n';
    }
    msg += '\n🏷️ Tags: ${tags.join(" | ")}\n\n'
        '💡 Fun Fact: $funFact\n\n'
        '━━━━━━━━━━━━━━━━━━━━\n'
        'Ask me about another dish or search to order this near you!';

    return _BotResponse(message: msg);
  }

  static final Map<String, Map<String, dynamic>> _dishNutritionDb = {
    'biryani': {
      'name': 'Chicken Biryani',
      'emoji': '🍛',
      'calories': '490-550 kcal',
      'protein': '28-32g',
      'carbs': '52-60g',
      'fat': '18-22g',
      'fiber': '3-4g',
      'serving': '1 plate (350g)',
      'best_time': '🌞 Lunch (12-2 PM) is ideal. Rich carbs provide sustained energy. Avoid late night as it is heavy to digest.',
      'benefits': [
        '🍗 High-quality protein from chicken aids muscle repair',
        '🌿 Spices like turmeric, cumin & cloves are anti-inflammatory',
        '🧠 Basmati rice provides steady energy without sugar spikes',
        '💪 Rich in B-vitamins and iron for blood health',
        '🦴 Contains phosphorus for strong bones',
      ],
      'tags': ['🍗 Non-Veg', '🌶️ Spicy', '🔥 High Protein', '⚡ Energy Rich'],
      'description': '🍛 A fragrant rice dish layered with marinated chicken, aromatic spices (saffron, cardamom, bay leaf), slow-cooked in dum style. Originated from royal Mughal kitchens — a celebration of taste and aroma.',
      'fun_fact': 'There are over 26 styles of biryani across India! Hyderabadi uses raw meat (kacchi), while Lucknowi uses pre-cooked meat (pakki).',
    },
    'dosa': {
      'name': 'Dosa (Plain / Masala)',
      'emoji': '🫓',
      'calories': '120-180 kcal',
      'protein': '4-6g',
      'carbs': '22-28g',
      'fat': '3-5g',
      'fiber': '2-3g',
      'serving': '1 dosa (100g)',
      'best_time': '🌅 Breakfast (7-9 AM) or evening snack (4-5 PM). Fermented batter is light on the stomach. Pair with sambar for a complete meal.',
      'benefits': [
        '🦠 Fermented batter is rich in probiotics for gut health',
        '❤️ Low in saturated fat, heart-friendly',
        '⚡ Quick source of carbohydrates for instant energy',
        '🧬 Fermentation increases B-vitamin bioavailability',
        '🌾 Gluten-free (rice and urad dal based)',
      ],
      'tags': ['🥬 Vegetarian', '🌿 Probiotic', '🫘 Gluten-Free', '💚 Light'],
      'description': '🫓 A crispy golden crepe from fermented rice and black gram batter. South Indian staple served with coconut chutney and sambar. Fermentation takes 8-12 hours for signature tangy flavor.',
      'fun_fact': 'Dosa batter fermentation naturally produces vitamin B12, making it one of the rare plant-based sources of this essential nutrient!',
    },
    'idly': {
      'name': 'Idly',
      'emoji': '⚪',
      'calories': '39-58 kcal',
      'protein': '2-3g',
      'carbs': '8-10g',
      'fat': '0.2-0.5g',
      'fiber': '1-2g',
      'serving': '1 idly (40g)',
      'best_time': '🌅 Morning breakfast (6-9 AM) is perfect! Light, easily digestible, gentle on stomach. Also great as a pre-workout meal.',
      'benefits': [
        '🪶 Ultra-low in fat — one of healthiest Indian breakfasts',
        '🦠 Fermented — excellent for gut microbiome health',
        '👶 Easy to digest, suitable for all ages',
        '⚡ Provides steady energy without heaviness',
        '🧬 Rich in B-vitamins from natural fermentation',
        '💆 Low glycemic index helps manage blood sugar',
      ],
      'tags': ['🥬 Vegetarian', '💚 Low-Fat', '👶 All Ages', '🏋️ Pre-workout'],
      'description': '⚪ Soft, fluffy steamed rice cakes from fermented rice and urad dal. A cornerstone of South Indian breakfast. Steaming preserves all nutrients.',
      'fun_fact': 'Idly is considered one of the healthiest breakfasts in the world! NASA reportedly studied it as potential space food due to its nutritional balance.',
    },
    'idli': {
      'name': 'Idli',
      'emoji': '⚪',
      'calories': '39-58 kcal',
      'protein': '2-3g',
      'carbs': '8-10g',
      'fat': '0.2-0.5g',
      'fiber': '1-2g',
      'serving': '1 idli (40g)',
      'best_time': '🌅 Morning breakfast (6-9 AM). Light and easily digestible.',
      'benefits': [
        '🪶 Ultra-low in fat',
        '🦠 Fermented — great for gut health',
        '👶 Easy to digest for all ages',
        '⚡ Steady energy without heaviness',
      ],
      'tags': ['🥬 Vegetarian', '💚 Low-Fat', '👶 All Ages'],
      'description': '⚪ Soft steamed rice cakes from fermented batter. A South Indian staple.',
      'fun_fact': 'Idli is one of the healthiest breakfasts in the world!',
    },
    'paneer': {
      'name': 'Paneer Butter Masala',
      'emoji': '🧀',
      'calories': '320-380 kcal',
      'protein': '18-22g',
      'carbs': '12-15g',
      'fat': '24-28g',
      'fiber': '2-3g',
      'serving': '1 bowl (200g)',
      'best_time': '🌞 Lunch (12-2 PM) is ideal. Protein and fat provide sustained energy. For dinner, use a smaller portion 2 hours before bed.',
      'benefits': [
        '💪 Excellent source of complete protein for vegetarians',
        '🦴 Rich in calcium for bone and teeth health',
        '🧀 Casein protein for slow amino acid release',
        '🔬 Tomatoes provide lycopene (antioxidant)',
        '🧈 Healthy fats support nutrient absorption',
      ],
      'tags': ['🥬 Vegetarian', '🔥 High Protein', '🦴 Calcium Rich', '🧈 Rich'],
      'description': '🧀 Soft cottage cheese in rich, creamy tomato-based gravy with butter, cream, and kasuri methi. A North Indian restaurant favorite.',
      'fun_fact': 'Paneer doesn\'t use rennet (animal enzyme), making it 100% vegetarian. India produces over 2 million tonnes of paneer annually!',
    },
    'pizza': {
      'name': 'Pizza (Margherita)',
      'emoji': '🍕',
      'calories': '250-300 kcal',
      'protein': '11-14g',
      'carbs': '30-36g',
      'fat': '10-14g',
      'fiber': '2-3g',
      'serving': '1 slice (110g)',
      'best_time': '🌞 Lunch or early dinner (12-6 PM). Avoid late night as cheese is heavy to digest. Pair with a salad for balance.',
      'benefits': [
        '🧀 Mozzarella provides calcium and protein',
        '🍅 Tomato sauce is rich in lycopene (powerful antioxidant)',
        '🌿 Fresh basil has anti-inflammatory properties',
        '⚡ Good source of quick energy from carbohydrates',
      ],
      'tags': ['🥬 Vegetarian', '🧀 Cheesy', '⚡ Energy Rich', '🌍 Italian'],
      'description': '🍕 Classic Italian flatbread with tomato sauce, mozzarella, and basil. Created in 1889 to honor Queen Margherita, with colors of the Italian flag.',
      'fun_fact': 'The world\'s largest pizza measured 13,580 sq ft made in Rome in 2012! Italians eat ~2.5 billion pizzas per year.',
    },
    'burger': {
      'name': 'Burger (Veg/Chicken)',
      'emoji': '🍔',
      'calories': '350-500 kcal',
      'protein': '15-25g',
      'carbs': '40-50g',
      'fat': '16-24g',
      'fiber': '3-4g',
      'serving': '1 burger (200g)',
      'best_time': '🌞 Lunch (12-2 PM) gives time to burn calories. Great post-workout for muscle recovery. Avoid late-night.',
      'benefits': [
        '💪 Balanced combo of protein, carbs, and fats',
        '🥬 Lettuce, tomato, onion add vitamins and fiber',
        '🧅 Onions contain quercetin (anti-inflammatory)',
        '🍖 Chicken patty is a lean protein source',
      ],
      'tags': ['🍗 Non-Veg/Veg', '⚡ Energy Dense', '💪 Protein Rich', '🏋️ Post-workout'],
      'description': '🍔 A bun with a seasoned patty, fresh lettuce, tomato, onion, pickles, and sauces. Modern burgers are gourmet creations worldwide.',
      'fun_fact': 'The most expensive burger ever sold cost 5,000 dollars and had gold leaf, lobster, and truffle!',
    },
    'parotta': {
      'name': 'Kerala Parotta',
      'emoji': '🫓',
      'calories': '200-260 kcal',
      'protein': '4-6g',
      'carbs': '32-38g',
      'fat': '8-12g',
      'fiber': '1-2g',
      'serving': '1 parotta (80g)',
      'best_time': '🌮 Dinner (7-8:30 PM) with curry is traditional. Also perfect for hearty lunch. Limit to 2-3 due to high carbs and fat.',
      'benefits': [
        '⚡ Quick energy from carbohydrates',
        '🧈 Layered flaky texture is very satisfying',
        '🫘 Pairs well with protein-rich curries for balanced meal',
      ],
      'tags': ['🥬 Vegetarian', '⚡ Energy Dense', '🌶️ Best with Curry', '🇮🇳 South Indian'],
      'description': '🫓 Layered, flaky flatbread from maida, water, and oil. Dough is stretched thin, coiled, and griddle-fried for crispy layers. Originated in Kerala.',
      'fun_fact': 'A skilled parotta maker can stretch the dough thin enough to read a newspaper through it! The best parottas have 10+ visible layers.',
    },
    'chai': {
      'name': 'Masala Chai',
      'emoji': '☕',
      'calories': '80-120 kcal',
      'protein': '3-4g',
      'carbs': '12-15g',
      'fat': '3-5g',
      'fiber': '0g',
      'serving': '1 cup (150ml)',
      'best_time': '🌅 Morning (7-9 AM) or afternoon (3-4 PM). Morning chai kickstarts metabolism. Afternoon chai combats post-lunch slump. Avoid after 6 PM.',
      'benefits': [
        '🧠 Tea polyphenols improve focus and alertness',
        '🌡️ Ginger and cardamom aid digestion',
        '🛡️ Cloves and cinnamon are antimicrobial',
        '❤️ Black tea flavonoids support cardiovascular health',
        '💆 L-theanine promotes calm alertness',
      ],
      'tags': ['🥬 Vegetarian', '☕ Caffeine', '🌿 Herbal Spices', '💆 Relaxing'],
      'description': '☕ Spiced milk tea with black tea, milk, sugar, cardamom, ginger, cloves, cinnamon. Every household has its own secret recipe.',
      'fun_fact': 'India produces over 1.3 billion kg of tea annually and consumes 80% domestically! "Chai" comes from Chinese "cha".',
    },
    'coffee': {
      'name': 'South Indian Filter Coffee',
      'emoji': '☕',
      'calories': '90-120 kcal',
      'protein': '3-4g',
      'carbs': '10-14g',
      'fat': '4-5g',
      'fiber': '0g',
      'serving': '1 tumbler (150ml)',
      'best_time': '🌅 Morning (6-8 AM) is ideal, 30 min after breakfast. Good as post-lunch pick-me-up (2-3 PM). Avoid after 4 PM.',
      'benefits': [
        '🧠 Caffeine boosts alertness, focus, cognition',
        '🏃 Enhances physical performance by 11-12%',
        '🔥 Boosts metabolic rate by 3-11%',
        '🛡️ Rich in antioxidants (chlorogenic acid)',
      ],
      'tags': ['🥬 Vegetarian', '☕ Caffeine', '🔥 Metabolism Boost', '🇮🇳 South Indian'],
      'description': '☕ Made by decocting finely ground coffee with chicory through a brass filter, mixed with hot frothy milk and sugar. The "meter" pour creates the frothy top.',
      'fun_fact': 'South Indian filter coffee was voted one of the top 10 beverages in the world! The brass filter tradition dates back to the 1600s.',
    },
    'samosa': {
      'name': 'Samosa',
      'emoji': '🔺',
      'calories': '250-300 kcal',
      'protein': '4-6g',
      'carbs': '28-32g',
      'fat': '14-18g',
      'fiber': '2-3g',
      'serving': '1 samosa (80g)',
      'best_time': '🌤️ Evening snack (4-5 PM) with chai! Also great party appetizer. Limit to 1-2 as they are deep-fried.',
      'benefits': [
        '🥔 Potato filling provides potassium and B6',
        '🌿 Green peas add plant protein and fiber',
        '🌶️ Spices like cumin and coriander aid digestion',
        '⚡ Quick energy snack for afternoon boost',
      ],
      'tags': ['🥬 Vegetarian', '🍟 Fried', '🌤️ Snack', '🇮🇳 Street Food'],
      'description': '🔺 Deep-fried triangular pastry with spiced potatoes, green peas, and onions. India\'s most iconic street food snack.',
      'fun_fact': 'Samosa originated in the Middle East ("sambosa") and was brought to India by traders in the 13th century! India consumes ~3 billion samosas per year.',
    },
    'pav bhaji': {
      'name': 'Pav Bhaji',
      'emoji': '🍛',
      'calories': '400-500 kcal',
      'protein': '10-14g',
      'carbs': '50-60g',
      'fat': '18-22g',
      'fiber': '6-8g',
      'serving': '1 plate (300g)',
      'best_time': '🌮 Evening snack (5-7 PM) or early dinner. Originally a quick meal for Mumbai textile mill workers.',
      'benefits': [
        '🥕 Contains 7+ vegetables rich in vitamins',
        '🥬 High fiber content from mixed vegetables',
        '🍅 Tomatoes and capsicum provide vitamin C',
        '🧈 Butter aids fat-soluble vitamin absorption',
      ],
      'tags': ['🥬 Vegetarian', '🌶️ Spicy', '💛 Mumbai Special', '🥕 Veggie Rich'],
      'description': '🍛 Thick, spicy mixed vegetable curry (bhaji) from potatoes, tomatoes, cauliflower, peas, capsicum — mashed and slow-cooked with pav bhaji masala and butter. Served with butter-toasted pav rolls.',
      'fun_fact': 'Pav Bhaji was invented in the 1850s in Mumbai as midnight meal for textile mill workers! "Pav" comes from Portuguese "pao" (bread).',
    },
    'gulab jamun': {
      'name': 'Gulab Jamun',
      'emoji': '🍮',
      'calories': '140-175 kcal',
      'protein': '3-4g',
      'carbs': '22-28g',
      'fat': '5-7g',
      'fiber': '0g',
      'serving': '1 piece (40g)',
      'best_time': '🎉 After lunch as dessert (1-2 PM). Traditional during festivals. Limit to 2 pieces due to high sugar.',
      'benefits': [
        '🥛 Khoya provides calcium and protein',
        '😊 Sugar triggers serotonin (mood booster)',
        '🌹 Rose water has calming, digestive properties',
        '💛 Cardamom in syrup aids digestion after heavy meals',
      ],
      'tags': ['🥬 Vegetarian', '🍬 Sweet', '🎉 Festive', '🌹 Rose-flavored'],
      'description': '🍮 Golden-brown dumplings from khoya and flour, deep-fried, then soaked in warm sugar syrup with rose water, saffron, and cardamom. India\'s most beloved dessert.',
      'fun_fact': '"Gulab" means rose (from rose-scented syrup) and "Jamun" refers to the Indian berry it resembles in shape. It has Persian origins!',
    },
    'chole': {
      'name': 'Chole Bhature',
      'emoji': '🫓',
      'calories': '450-550 kcal',
      'protein': '14-18g',
      'carbs': '55-65g',
      'fat': '20-25g',
      'fiber': '8-10g',
      'serving': '1 plate (350g)',
      'best_time': '🌅 Breakfast/brunch (8-11 AM) is traditional Punjabi timing. Chickpeas provide sustained energy. Avoid at night.',
      'benefits': [
        '🫘 Chickpeas are packed with plant protein and fiber',
        '🦴 Rich in iron, manganese, and folate',
        '💪 Low glycemic index regulates blood sugar',
        '🌿 Amchur (dry mango) provides vitamin C',
      ],
      'tags': ['🥬 Vegetarian', '💪 High Protein', '🫘 Legume-based', '🇮🇳 Punjabi'],
      'description': '🫓 Spicy chickpea curry (chole) with deep-fried puffed bread (bhature). Chole is slow-cooked with tea leaves (for color), amchur, and pomegranate seeds.',
      'fun_fact': 'The secret to the dark color is "chole masala" with tea leaves and black cardamom! Delhi\'s Sita Ram Diwan Chand has served it since 1950.',
    },
    'naan': {
      'name': 'Butter Naan',
      'emoji': '🫓',
      'calories': '260-310 kcal',
      'protein': '7-9g',
      'carbs': '42-48g',
      'fat': '8-10g',
      'fiber': '2g',
      'serving': '1 naan (90g)',
      'best_time': '🌞 Lunch or dinner. Best with protein-rich curry. Limit to 1-2 as it is calorie-dense.',
      'benefits': [
        '⚡ Quick source of carbohydrates for energy',
        '🧈 Butter aids fat-soluble vitamin absorption',
        '🫘 With dal, provides complete protein',
        '🧬 Yogurt in dough adds probiotics',
      ],
      'tags': ['🥬 Vegetarian', '🧈 Buttery', '🔥 Tandoor-baked', '🇮🇳 North Indian'],
      'description': '🫓 Leavened flatbread baked in clay tandoor, brushed with butter. Yogurt-based dough gives it soft, pillowy texture with tandoor char spots.',
      'fun_fact': '"Naan" comes from Persian "non" (bread). First appeared in Indian records in 1300 AD at the Imperial Court!',
    },
    'pasta': {
      'name': 'Pasta (Penne/Spaghetti)',
      'emoji': '🍝',
      'calories': '350-420 kcal',
      'protein': '12-16g',
      'carbs': '50-58g',
      'fat': '12-16g',
      'fiber': '3-4g',
      'serving': '1 bowl (250g)',
      'best_time': '🌞 Lunch (12-2 PM) to burn carbs. Good pre-workout meal 2 hrs before exercise. Red sauce is lighter than white sauce.',
      'benefits': [
        '⚡ Complex carbs provide sustained energy',
        '🍅 Tomato sauces are rich in lycopene',
        '🧀 Cheese adds calcium and protein',
        '🌿 Basil, oregano are anti-inflammatory',
      ],
      'tags': ['🥬 Vegetarian', '⚡ Energy Rich', '🌍 Italian', '🏋️ Pre-workout'],
      'description': '🍝 Italian pasta cooked al dente in sauces from Arrabiata to Alfredo. Indian versions add spicy twist with green chilies.',
      'fun_fact': 'There are over 350 different pasta shapes, each designed to hold specific types of sauce!',
    },
    'kebab': {
      'name': 'Seekh Kebab',
      'emoji': '🥩',
      'calories': '250-320 kcal',
      'protein': '22-28g',
      'carbs': '5-8g',
      'fat': '16-20g',
      'fiber': '1-2g',
      'serving': '4 pieces (150g)',
      'best_time': '🌮 Dinner appetizer (7-8 PM). High protein ideal post-workout. Grilled is healthier than fried.',
      'benefits': [
        '💪 Very high in protein for muscle building',
        '🔥 Grilled preparation reduces excess fat',
        '🌿 Cumin, coriander boost metabolism',
        '🥩 Iron-rich from minced meat',
      ],
      'tags': ['🍗 Non-Veg', '🔥 High Protein', '💪 Muscle Building', '🔥 Grilled'],
      'description': '🥩 Minced meat with onions, herbs, and spices, shaped onto skewers and grilled in tandoor. Charred exterior with juicy interior.',
      'fun_fact': 'Kebabs were originally created by Turkish soldiers grilling meat on their swords over campfires!',
    },
    'lassi': {
      'name': 'Lassi (Sweet/Mango)',
      'emoji': '🥛',
      'calories': '180-250 kcal',
      'protein': '6-8g',
      'carbs': '28-35g',
      'fat': '5-8g',
      'fiber': '0-1g',
      'serving': '1 glass (250ml)',
      'best_time': '🌞 After lunch (1-2 PM) is traditional. Helps cool down in summer. Great with spicy meals.',
      'benefits': [
        '🦠 Rich in probiotics for gut health',
        '🥛 High calcium for strong bones',
        '🌡️ Natural coolant reduces body heat',
        '💆 L-tryptophan promotes relaxation',
      ],
      'tags': ['🥬 Vegetarian', '🥛 Dairy', '❄️ Cooling', '🦠 Probiotic'],
      'description': '🥛 Traditional Punjabi yogurt drink blended with sugar or mango pulp, water, and ice. Garnished with dry fruits and saffron.',
      'fun_fact': 'Lassi has been consumed in India for over 1000 years! Punjab shops serve it in enormous steel glasses holding nearly half a liter!',
    },
    'ice cream': {
      'name': 'Ice Cream',
      'emoji': '🍦',
      'calories': '200-270 kcal',
      'protein': '3-5g',
      'carbs': '24-30g',
      'fat': '11-16g',
      'fiber': '0-1g',
      'serving': '1 scoop (100g)',
      'best_time': '🌤️ Afternoon treat (2-4 PM). Good after spicy meals. Avoid late night and early morning.',
      'benefits': [
        '🥛 Good source of calcium and phosphorus',
        '😊 Triggers endorphin release — instant mood lifter!',
        '⚡ Quick energy from sugar and fat',
        '🧬 Contains vitamins A, D, B12 from milk',
      ],
      'tags': ['🥬 Vegetarian', '🍬 Sweet', '🍦 Cold', '😊 Mood Booster'],
      'description': '🍦 Frozen dairy dessert from cream, milk, sugar, and flavoring. Popular Indian flavors include mango, kulfi, pista, butterscotch.',
      'fun_fact': 'It takes about 50 licks to finish a single scoop! The most popular flavor in India is butterscotch!',
    },
    'brownie': {
      'name': 'Chocolate Brownie',
      'emoji': '🍫',
      'calories': '350-420 kcal',
      'protein': '4-6g',
      'carbs': '45-55g',
      'fat': '18-22g',
      'fiber': '2-3g',
      'serving': '1 piece (80g)',
      'best_time': '🌤️ Post-lunch dessert (1-2 PM) or afternoon treat (3-4 PM). Dark chocolate versions are healthier.',
      'benefits': [
        '🍫 Dark chocolate rich in antioxidants (flavonoids)',
        '😊 Triggers serotonin and endorphin release',
        '🧠 Cocoa improves blood flow to the brain',
      ],
      'tags': ['🥬 Vegetarian', '🍬 Sweet', '🍫 Chocolate', '😊 Mood Booster'],
      'description': '🍫 Rich, dense chocolate dessert with fudgy center. Often served warm with vanilla ice cream for the ultimate experience.',
      'fun_fact': 'The brownie was invented by accident in 1893 when a chef forgot to add baking powder to chocolate cake batter!',
    },
    'noodles': {
      'name': 'Noodles (Hakka/Schezwan)',
      'emoji': '🍜',
      'calories': '350-450 kcal',
      'protein': '8-12g',
      'carbs': '48-55g',
      'fat': '14-18g',
      'fiber': '3-4g',
      'serving': '1 plate (300g)',
      'best_time': '🌞 Lunch (12-2 PM) or early dinner (6-7 PM). Add veggies/chicken for balanced meal.',
      'benefits': [
        '⚡ Quick energy from carbohydrates',
        '🥕 Stir-fried vegetables add vitamins and fiber',
        '🌶️ Schezwan sauce capsaicin boosts metabolism',
        '🧅 Garlic and ginger boost immunity',
      ],
      'tags': ['🥬 Veg/Non-Veg', '⚡ Energy Rich', '🌶️ Spicy', '🇨🇳 Indo-Chinese'],
      'description': '🍜 Indo-Chinese stir-fried noodles with vegetables, soy sauce, and spices on high heat. The Indian version is much spicier than traditional Chinese.',
      'fun_fact': 'Indo-Chinese cuisine was invented by Chinese immigrants in Kolkata! It is a uniquely Indian creation that does not exist in China.',
    },
    'fried rice': {
      'name': 'Fried Rice',
      'emoji': '🍚',
      'calories': '300-380 kcal',
      'protein': '8-12g',
      'carbs': '45-52g',
      'fat': '10-14g',
      'fiber': '2-3g',
      'serving': '1 plate (300g)',
      'best_time': '🌞 Lunch (12-2 PM). Pair with soup for complete meal.',
      'benefits': [
        '⚡ Carbohydrate-rich for sustained energy',
        '🥕 Vegetables add essential vitamins',
        '🥚 Egg version adds protein and B-vitamins',
        '🌿 Sesame oil has heart-healthy fats',
      ],
      'tags': ['🥬 Veg/Non-Veg', '⚡ Energy Rich', '🇨🇳 Indo-Chinese', '🍚 Rice-based'],
      'description': '🍚 Day-old rice stir-fried on high heat with vegetables, eggs, soy sauce. The secret is using cold leftover rice — fresh rice makes it mushy.',
      'fun_fact': 'The wok hei ("breath of the wok") flavor comes from cooking at extremely high temperatures of over 1200 degrees!',
    },
    'vada pav': {
      'name': 'Vada Pav',
      'emoji': '🍔',
      'calories': '280-340 kcal',
      'protein': '6-8g',
      'carbs': '38-44g',
      'fat': '12-16g',
      'fiber': '3-4g',
      'serving': '1 vada pav (120g)',
      'best_time': '🌤️ Late morning snack (10-11 AM) or evening (4-5 PM). Perfect with cutting chai for the quintessential Mumbai experience.',
      'benefits': [
        '🥔 Potato provides potassium, B6, vitamin C',
        '🌶️ Green chutney is rich in vitamins A and K',
        '🌿 Garlic chutney has antimicrobial properties',
        '⚡ Quick, satisfying street food energy boost',
      ],
      'tags': ['🥬 Vegetarian', '🍟 Fried', '💛 Mumbai Iconic', '🚌 Street Food'],
      'description': '🍔 Mumbai\'s iconic street food — a spiced potato fritter in gram flour batter inside a pav bun with green chutney, garlic chutney, and fried green chilies.',
      'fun_fact': 'Vada Pav was invented by Ashok Vaidya near Dadar station in 1966. Mumbai sells an estimated 2 crore vada pavs daily!',
    },
  };

  bool _hasSpecificFood(String q) =>
      q.contains('pizza') || q.contains('biryani') || q.contains('dosa') ||
      q.contains('idli') || q.contains('idly') || q.contains('parotta') ||
      q.contains('chai') || q.contains('coffee') || q.contains('naan') ||
      q.contains('kebab') || q.contains('tandoori') || q.contains('paneer') ||
      q.contains('chicken') || q.contains('mutton') || q.contains('fish') ||
      q.contains('breakfast') || q.contains('dinner') || q.contains('lunch') ||
      q.contains('snack') || q.contains('dessert') || q.contains('sweet') ||
      q.contains('burger') || q.contains('noodles') || q.contains('fried rice') ||
      q.contains('ice cream') || q.contains('cake') || q.contains('juice');

  int? _extractBudget(String q) {
    final match = RegExp(r'(\d+)').firstMatch(q);
    if (match != null) return int.parse(match.group(1)!);
    if (q.contains('cheap') || q.contains('budget')) return 150;
    if (q.contains('affordable')) return 200;
    return null;
  }

  String? _extractCuisine(String q) {
    if (q.contains('south indian')) return 'South Indian';
    if (q.contains('north indian')) return 'North Indian';
    if (q.contains('continental')) return 'Continental';
    if (q.contains('pizza') || q.contains('italian')) return 'Pizza';
    if (q.contains('biryani')) return 'Biryani';
    if (q.contains('bbq') || q.contains('barbecue')) return 'BBQ';
    if (q.contains('chai') || q.contains('tea')) return 'Chai';
    if (q.contains('street food')) return 'Street Food';
    if (q.contains('dosa')) return 'Dosa';
    if (q.contains('idli') || q.contains('idly')) return 'Idly';
    if (q.contains('parotta') || q.contains('paratha')) return 'Parotta';
    if (q.contains('burger')) return 'Burger';
    if (q.contains('chinese')) return 'Chinese';
    return null;
  }

  int _extractPriceFromRTP(String rtp) {
    final match = RegExp(r'Rs\s*(\d+)').firstMatch(rtp);
    return match != null ? int.parse(match.group(1)!) : 999;
  }

  int _extractTimeFromRTP(String rtp) {
    final match = RegExp(r'(\d+)\s*mins').firstMatch(rtp);
    return match != null ? int.parse(match.group(1)!) : 60;
  }

  double _extractRatingFromRTP(String rtp) {
    final match = RegExp(r'(\d+\.?\d*)').firstMatch(rtp);
    return match != null ? double.parse(match.group(1)!) : 0;
  }

  _FoodSuggestion _toSuggestion(SpotlightBestTopFood r, {List<String>? matchedDishes}) {
    return _FoodSuggestion(
      restaurantName: r.name,
      cuisine: r.desc,
      rating: _extractRatingFromRTP(r.ratingTimePrice).toString(),
      priceForTwo: '₹${_extractPriceFromRTP(r.ratingTimePrice)}',
      deliveryTime: '${_extractTimeFromRTP(r.ratingTimePrice)} mins',
      image: r.image,
      spotlightData: r,
      matchedDishes: matchedDishes ?? [],
    );
  }

  List<_FoodSuggestion> _filterByBudget(List<SpotlightBestTopFood> restaurants, int budget) {
    return restaurants
        .where((r) => _extractPriceFromRTP(r.ratingTimePrice) <= budget)
        .map((r) => _toSuggestion(r))
        .toList();
  }

  List<_FoodSuggestion> _filterByCuisine(List<SpotlightBestTopFood> restaurants, String cuisine) {
    final lower = cuisine.toLowerCase();
    final results = <_FoodSuggestion>[];

    for (final r in restaurants) {
      List<String> matched = [];
      if (r.desc.toLowerCase().contains(lower) || r.name.toLowerCase().contains(lower)) {
        final menus = RestaurantDetail.getMenusFor(r.name);
        for (final menuList in menus) {
          for (final dish in menuList) {
            if (dish.title.toLowerCase().contains(lower) ||
                dish.desc.toLowerCase().contains(lower)) {
              matched.add('${dish.title} - ${dish.price}');
            }
          }
        }
        results.add(_toSuggestion(r, matchedDishes: matched.take(3).toList()));
      }
    }
    return results;
  }

  List<_FoodSuggestion> _filterByDiet(List<SpotlightBestTopFood> restaurants, bool isVeg) {
    if (isVeg) {
      // Pure veg - only restaurants with veg keywords, exclude non-veg indicators
      return restaurants
          .where((r) {
            final nameLower = r.name.toLowerCase();
            final descLower = r.desc.toLowerCase();
            // Include: known veg restaurants, south indian (mostly veg)
            final isVegRestaurant = nameLower.contains('veg') ||
                nameLower.contains('a2b') ||
                nameLower.contains('bhavan') ||
                nameLower.contains('sangeetha') ||
                nameLower.contains('saravana') ||
                nameLower.contains('idly') ||
                descLower.contains('pure veg') ||
                descLower.contains('south indian');
            // Exclude: non-veg restaurants
            final isNonVeg = nameLower.contains('bbq') ||
                nameLower.contains('biryani') ||
                nameLower.contains('chicken') ||
                nameLower.contains('kfc') ||
                nameLower.contains('mass') ||
                nameLower.contains('sea emperor') ||
                nameLower.contains('fireflies');
            return isVegRestaurant && !isNonVeg;
          })
          .map((r) => _toSuggestion(r, matchedDishes: ['✅ Pure Vegetarian']))
          .toList();
    } else {
      // Non-veg - explicitly non-veg restaurants only
      return restaurants
          .where((r) {
            final nameLower = r.name.toLowerCase();
            final descLower = r.desc.toLowerCase();
            return nameLower.contains('bbq') ||
                nameLower.contains('biryani') ||
                nameLower.contains('chicken') ||
                nameLower.contains('kfc') ||
                nameLower.contains('mass') ||
                nameLower.contains('sea emperor') ||
                nameLower.contains('fireflies') ||
                descLower.contains('north indian') ||
                descLower.contains('mughal') ||
                descLower.contains('non-veg') ||
                descLower.contains('chicken') ||
                descLower.contains('bbq');
          })
          .map((r) => _toSuggestion(r, matchedDishes: ['🍖 Non-Veg Available']))
          .toList();
    }
  }

  List<_FoodSuggestion> _filterByRating(List<SpotlightBestTopFood> restaurants) {
    final sorted = [...restaurants];
    sorted.sort((a, b) =>
        _extractRatingFromRTP(b.ratingTimePrice).compareTo(_extractRatingFromRTP(a.ratingTimePrice)));
    return sorted.take(5).map((r) => _toSuggestion(r)).toList();
  }

  List<_FoodSuggestion> _filterByDeliveryTime(List<SpotlightBestTopFood> restaurants) {
    final sorted = [...restaurants];
    sorted.sort((a, b) =>
        _extractTimeFromRTP(a.ratingTimePrice).compareTo(_extractTimeFromRTP(b.ratingTimePrice)));
    return sorted.take(5).map((r) => _toSuggestion(r)).toList();
  }

  List<_FoodSuggestion> _filterBySpicy(List<SpotlightBestTopFood> restaurants) {
    final results = <_FoodSuggestion>[];
    for (final r in restaurants) {
      final menus = RestaurantDetail.getMenusFor(r.name);
      List<String> matched = [];
      for (final menuList in menus) {
        for (final dish in menuList) {
          if (dish.title.toLowerCase().contains('spicy') ||
              dish.title.toLowerCase().contains('pepper') ||
              dish.title.toLowerCase().contains('chilli') ||
              dish.title.toLowerCase().contains('masala') ||
              dish.title.toLowerCase().contains('hot') ||
              dish.desc.toLowerCase().contains('spicy')) {
            matched.add('🌶️ ${dish.title} - ${dish.price}');
          }
        }
      }
      if (matched.isNotEmpty) {
        results.add(_toSuggestion(r, matchedDishes: matched.take(3).toList()));
      }
    }
    // Also add restaurants known for spicy food
    if (results.isEmpty) {
      for (final r in restaurants) {
        if (r.name.toLowerCase().contains('biryani') ||
            r.desc.toLowerCase().contains('north indian')) {
          results.add(_toSuggestion(r, matchedDishes: ['🌶️ Known for spicy cuisine']));
        }
      }
    }
    return results;
  }

  _BotResponse _searchSpecificFood(List<SpotlightBestTopFood> restaurants, String query) {
    final results = <_FoodSuggestion>[];

    for (final r in restaurants) {
      final menus = RestaurantDetail.getMenusFor(r.name);
      List<String> matched = [];
      for (final menuList in menus) {
        for (final dish in menuList) {
          if (dish.title.toLowerCase().contains(query) ||
              dish.desc.toLowerCase().contains(query)) {
            matched.add('${dish.title} - ${dish.price}');
          }
        }
      }
      if (matched.isNotEmpty) {
        results.add(_toSuggestion(r, matchedDishes: matched.take(3).toList()));
      }
    }

    return _BotResponse(
      message: results.isNotEmpty
          ? '🔍 Found ${results.length} restaurant(s) with matching dishes:'
          : '',
      suggestions: results,
    );
  }

  List<_FoodSuggestion> _generalSearch(List<SpotlightBestTopFood> restaurants, String query) {
    final words = query.split(' ').where((w) => w.length > 2).toList();
    final results = <_FoodSuggestion>[];

    for (final r in restaurants) {
      for (final word in words) {
        if (r.name.toLowerCase().contains(word) ||
            r.desc.toLowerCase().contains(word)) {
          results.add(_toSuggestion(r));
          break;
        }
      }
    }

    if (results.isEmpty) {
      for (final r in restaurants) {
        final menus = RestaurantDetail.getMenusFor(r.name);
        List<String> matched = [];
        for (final menuList in menus) {
          for (final dish in menuList) {
            for (final word in words) {
              if (dish.title.toLowerCase().contains(word)) {
                matched.add('${dish.title} - ${dish.price}');
              }
            }
          }
        }
        if (matched.isNotEmpty) {
          results.add(_toSuggestion(r, matchedDishes: matched.take(3).toList()));
        }
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepOrange.shade800,
              Colors.deepOrange.shade400,
              Colors.orange.shade200,
              Colors.white,
            ],
            stops: const [0.0, 0.15, 0.3, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    child: Column(
                      children: [
                        _buildQuickActions(),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length + (_isTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _messages.length && _isTyping) {
                                return _buildTypingIndicator();
                              }
                              return _buildMessageBubble(_messages[index]);
                            },
                          ),
                        ),
                        _buildInputField(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🤖', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Foodora AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    height: 8,
                    width: 8,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Online • Ready to help',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // History button
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Order History',
            onPressed: () => _handleSend('Show my order history'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _messages.clear();
                _chatHistory.clear();
              });
              _addBotMessage(
                'Chat cleared! 🧹 How can I help you find food today?',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final chips = [
      {'label': '🥬 Pure Veg', 'query': 'pure veg options'},
      {'label': '🍖 Non-Veg', 'query': 'non veg restaurants'},
      {'label': '💰 Under ₹150', 'query': 'under 150'},
      {'label': '🍚 South Indian', 'query': 'south indian food'},
      {'label': '⚡ Quick delivery', 'query': 'quick delivery'},
      {'label': '⭐ Best rated', 'query': 'best rated restaurants'},
      {'label': '🌶️ Spicy', 'query': 'spicy food'},
      {'label': '🔮 Suggest for me', 'query': 'suggest something for me'},
      {'label': '📜 My Orders', 'query': 'my order history'},
      {'label': '🍕 Pizza', 'query': 'pizza'},
      {'label': '🍗 Biryani', 'query': 'biryani'},
      {'label': '☕ Chai', 'query': 'chai'},
    ];

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: chips.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ActionChip(
            label: Text(
              chips[index]['label']!,
              style: const TextStyle(fontSize: 13),
            ),
            backgroundColor: Colors.orange[50],
            side: BorderSide(color: Colors.orange.shade200),
            onPressed: () => _handleSend(chips[index]['query']!),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isUser) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🤖', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Colors.deepOrange[600]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              if (message.isUser) const SizedBox(width: 8),
            ],
          ),
          if (message.suggestions != null && message.suggestions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 40),
              child: Column(
                children: message.suggestions!
                    .map((s) => _buildSuggestionCard(s))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(_FoodSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (suggestion.spotlightData != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RestaurantDetailScreen(
                  restaurant: suggestion.spotlightData,
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      suggestion.image,
                      height: 55,
                      width: 55,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.restaurantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          suggestion.cuisine,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.orange[700]),
                            const SizedBox(width: 2),
                            Text(suggestion.rating,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 10),
                            Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(suggestion.deliveryTime,
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(suggestion.priceForTwo,
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange[300]),
                ],
              ),
              if (suggestion.matchedDishes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🍽️ Matching dishes:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...suggestion.matchedDishes.map((d) => Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Text(
                              '• $d',
                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              shape: BoxShape.circle,
            ),
            child: const Text('🤖', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(18),
            ),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[400]!.withValues(
                          alpha: 0.4 + (_pulseController.value * 0.6 * ((i + 1) / 3)),
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ask me about food...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onSubmitted: _handleSend,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange.shade600, Colors.orange.shade400],
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: () => _handleSend(_messageController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotResponse {
  final String message;
  final List<_FoodSuggestion> suggestions;

  _BotResponse({required this.message, this.suggestions = const []});
}
