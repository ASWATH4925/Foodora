import 'package:flutter/material.dart';
import 'package:swiggy_ui/models/spotlight_best_top_food.dart';

class FavouriteProvider extends ChangeNotifier {
  final Set<String> _favouriteNames = {};

  Set<String> get favouriteNames => {..._favouriteNames};

  bool isFavourite(String name) => _favouriteNames.contains(name);

  void toggleFavourite(String name) {
    if (_favouriteNames.contains(name)) {
      _favouriteNames.remove(name);
    } else {
      _favouriteNames.add(name);
    }
    notifyListeners();
  }

  void removeFavourite(String name) {
    _favouriteNames.remove(name);
    notifyListeners();
  }

  /// Returns SpotlightBestTopFood objects for all favourited restaurant names.
  List<SpotlightBestTopFood> get favouriteRestaurants {
    final allRestaurants = <SpotlightBestTopFood>[
      ...SpotlightBestTopFood.getPopularAllRestaurants(),
      ...SpotlightBestTopFood.getAllRestaurantsNearby(),
      ...SpotlightBestTopFood.getSpotlightRestaurants().expand((l) => l),
      ...SpotlightBestTopFood.getBestRestaurants().expand((l) => l),
      ...SpotlightBestTopFood.getTopRestaurants().expand((l) => l),
    ];

    final seen = <String>{};
    final unique = <SpotlightBestTopFood>[];
    for (final r in allRestaurants) {
      if (!seen.contains(r.name) && _favouriteNames.contains(r.name)) {
        seen.add(r.name);
        unique.add(r);
      }
    }
    return unique;
  }
}
