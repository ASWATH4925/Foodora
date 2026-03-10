class RestaurantDetail {
  const RestaurantDetail({
    required this.title,
    required this.price,
    this.image = '',
    this.desc = '',
  });

  final String title;
  final String price;
  final String image;
  final String desc;

  static List<RestaurantDetail> getBreakfast() {
    return const [
      RestaurantDetail(
        title: 'Idly(2Pcs) (Breakfast)',
        price: 'Rs48',
        image: 'assets/images/food1.jpg',
        desc: 'A healthy breakfast item and an authentic south indian delicacy! Steamed and fluffy rice cake..more',
      ),
      RestaurantDetail(
        title: 'Sambar Idly (2Pcs)',
        image: 'assets/images/food2.jpg',
        price: 'Rs70',
      ),
      RestaurantDetail(
        title: 'Ghee Pongal',
        image: 'assets/images/food3.jpg',
        price: 'Rs85',
        desc: 'Cute, button idlis with authentic. South Indian sambar and coconut chutney gives the per..more',
      ),
      RestaurantDetail(
        title: 'Boori (1Set)',
        image: 'assets/images/food4.jpg',
        price: 'Rs85',
      ),
      RestaurantDetail(
        title: 'Podi Idly(2Pcs)',
        image: 'assets/images/food5.jpg',
        price: 'Rs110',
      ),
      RestaurantDetail(
        title: 'Mini Idly with Sambar',
        image: 'assets/images/food6.jpg',
        price: 'Rs85',
        desc: 'Cute, button idlis with authentic. South Indian sambar and coconut chutney gives the per..more',
      ),
    ];
  }

  static List<RestaurantDetail> getAllTimeFavFoods() {
    return const [
      RestaurantDetail(
        title: 'Plain Dosa',
        price: 'Rs30',
        desc: 'A healthy breakfast item and an authentic south indian delicacy!',
      ),
      RestaurantDetail(
        title: 'Rava Dosa',
        price: 'Rs70',
      ),
      RestaurantDetail(
        title: 'Onion Dosa',
        price: 'Rs85',
        desc: 'Cute, button dosas with authentic. South Indian sambar and coconut chutney gives the per..more',
      ),
      RestaurantDetail(
        title: 'Onion Uttapam',
        price: 'Rs85',
      ),
      RestaurantDetail(
        title: 'Tomato Uttapam',
        price: 'Rs110',
      ),
      RestaurantDetail(
        title: 'Onion Dosa & Sambar Vadai',
        price: 'Rs85',
      ),
    ];
  }

  static List<RestaurantDetail> getOtherDishes() {
    return const [
      RestaurantDetail(
        title: 'Kuzhi Paniyaram Karam (4Pcs)',
        price: 'Rs70',
      ),
      RestaurantDetail(
        title: 'Kuzhi Paniyaram Sweet (4Pcs)',
        price: 'Rs70',
      ),
      RestaurantDetail(
        title: 'Kuzhi Paniyaram Sweet & Karam (4Pcs)',
        price: 'Rs110',
      ),
      RestaurantDetail(
        title: 'Ghee Kuzhi Paniyaram',
        price: 'Rs85',
      ),
    ];
  }

  // ── Per‑restaurant menus ──────────────────────────────────────
  // ignore: unused_field
  static final Map<String, List<List<RestaurantDetail>>> _restaurantMenus = {
    'Namma Veedu Vasanta Bhavan': [
      getBreakfast(),
      getAllTimeFavFoods(),
      getOtherDishes(),
    ],
    'Namma Veedu Bhavan': [
      getBreakfast(),
      getAllTimeFavFoods(),
      getOtherDishes(),
    ],
  };

  static List<String> getMenuCategoriesFor(String name) {
    final key = _menuKey(name);
    return _menuData[key]?['categories'] as List<String>? ??
        ['Breakfast', 'All Time Favourite', 'Other Dishes'];
  }

  static List<List<RestaurantDetail>> getMenusFor(String name) {
    final key = _menuKey(name);
    final data = _menuData[key];
    if (data != null) {
      return data['items'] as List<List<RestaurantDetail>>;
    }
    // Fallback
    return [getBreakfast(), getAllTimeFavFoods(), getOtherDishes()];
  }

  static String _menuKey(String name) {
    final lower = name.toLowerCase().trim();
    for (final key in _menuData.keys) {
      if (lower.contains(key.toLowerCase()) || key.toLowerCase().contains(lower)) {
        return key;
      }
    }
    // Hash-based fallback to give different restaurants different menus
    final hash = lower.hashCode.abs() % _fallbackMenuSets.length;
    return _fallbackMenuSets[hash];
  }

  static final List<String> _fallbackMenuSets = _menuData.keys.toList();

  static final Map<String, Map<String, dynamic>> _menuData = {
    'Breakfast Expresss': {
      'categories': ['Continental Breakfast', 'Pancakes & Waffles', 'Beverages'],
      'items': [
        const [
          RestaurantDetail(title: 'English Breakfast', price: 'Rs220', image: 'assets/images/food1.jpg', desc: 'Eggs, toast, baked beans, grilled tomato and sausage'),
          RestaurantDetail(title: 'Masala Omelette', price: 'Rs120', image: 'assets/images/food2.jpg', desc: 'Fluffy omelette with onions, tomatoes and green chili'),
          RestaurantDetail(title: 'French Toast', price: 'Rs150', image: 'assets/images/food3.jpg'),
          RestaurantDetail(title: 'Egg Bhurji', price: 'Rs100', image: 'assets/images/food4.jpg', desc: 'Spicy scrambled eggs Indian style'),
        ],
        const [
          RestaurantDetail(title: 'Classic Pancakes', price: 'Rs180', desc: 'Fluffy pancakes with maple syrup and butter'),
          RestaurantDetail(title: 'Belgian Waffle', price: 'Rs200', desc: 'Crispy waffle with fresh fruits and cream'),
          RestaurantDetail(title: 'Chocolate Pancakes', price: 'Rs220', desc: 'Rich chocolate pancakes with ice cream'),
        ],
        const [
          RestaurantDetail(title: 'Filter Coffee', price: 'Rs40'),
          RestaurantDetail(title: 'Masala Chai', price: 'Rs30'),
          RestaurantDetail(title: 'Fresh Orange Juice', price: 'Rs80'),
        ],
      ],
    },
    'Namma Veedu Bhavan': {
      'categories': ['Breakfast', 'All Time Favourite', 'Kozhukattai & Paniyarams'],
      'items': [getBreakfast(), getAllTimeFavFoods(), getOtherDishes()],
    },
    'A2B Chennai': {
      'categories': ['South Indian Specials', 'North Indian', 'Sweets & Desserts'],
      'items': [
        const [
          RestaurantDetail(title: 'Ghee Roast Dosa', price: 'Rs95', image: 'assets/images/food3.jpg', desc: 'Crispy dosa roasted in pure ghee, served with chutneys'),
          RestaurantDetail(title: 'Mysore Masala Dosa', price: 'Rs110', image: 'assets/images/food5.jpg', desc: 'Spicy red chutney spread dosa with potato filling'),
          RestaurantDetail(title: 'Curd Vada (2 Pcs)', price: 'Rs75', image: 'assets/images/food1.jpg'),
          RestaurantDetail(title: 'Rava Kesari', price: 'Rs60', image: 'assets/images/food6.jpg', desc: 'Sweet semolina dessert with cashews'),
        ],
        const [
          RestaurantDetail(title: 'Paneer Butter Masala', price: 'Rs180', desc: 'Rich creamy tomato gravy with soft paneer cubes'),
          RestaurantDetail(title: 'Aloo Gobi', price: 'Rs140', desc: 'Classic potato and cauliflower curry'),
          RestaurantDetail(title: 'Dal Fry', price: 'Rs120', desc: 'Tempered yellow lentils'),
          RestaurantDetail(title: 'Jeera Rice', price: 'Rs100'),
        ],
        const [
          RestaurantDetail(title: 'Gulab Jamun (2 Pcs)', price: 'Rs50', desc: 'Soft milk dumplings in sugar syrup'),
          RestaurantDetail(title: 'Mysore Pak', price: 'Rs40', desc: 'Traditional ghee sweet'),
          RestaurantDetail(title: 'Badam Halwa', price: 'Rs70'),
        ],
      ],
    },
    'Biryani Expresss': {
      'categories': ['Biryani', 'Starters', 'Breads & Rice'],
      'items': [
        const [
          RestaurantDetail(title: 'Chicken Biryani', price: 'Rs199', image: 'assets/images/food4.jpg', desc: 'Aromatic basmati rice with tender chicken, slow-cooked with spices'),
          RestaurantDetail(title: 'Mutton Biryani', price: 'Rs280', image: 'assets/images/food7.jpg', desc: 'Rich mutton pieces with fragrant rice'),
          RestaurantDetail(title: 'Egg Biryani', price: 'Rs149', image: 'assets/images/food8.jpg'),
          RestaurantDetail(title: 'Veg Biryani', price: 'Rs139', image: 'assets/images/food3.jpg', desc: 'Mixed vegetables with spiced basmati rice'),
          RestaurantDetail(title: 'Prawn Biryani', price: 'Rs320', desc: 'Succulent prawns with saffron rice'),
        ],
        const [
          RestaurantDetail(title: 'Chicken 65', price: 'Rs180', desc: 'Crispy deep-fried chicken with spices'),
          RestaurantDetail(title: 'Paneer 65', price: 'Rs160', desc: 'Spicy paneer fritters'),
          RestaurantDetail(title: 'Gobi Manchurian', price: 'Rs140'),
        ],
        const [
          RestaurantDetail(title: 'Butter Naan', price: 'Rs40'),
          RestaurantDetail(title: 'Garlic Naan', price: 'Rs50'),
          RestaurantDetail(title: 'Jeera Rice', price: 'Rs90'),
        ],
      ],
    },
    'BBQ King': {
      'categories': ['BBQ Platters', 'Grills', 'Sides & Beverages'],
      'items': [
        const [
          RestaurantDetail(title: 'BBQ Chicken Platter', price: 'Rs350', image: 'assets/images/food7.jpg', desc: 'Smoky grilled chicken with BBQ sauce and coleslaw'),
          RestaurantDetail(title: 'Tandoori Chicken Full', price: 'Rs420', image: 'assets/images/food8.jpg', desc: 'Whole chicken marinated in yogurt and spices'),
          RestaurantDetail(title: 'Seekh Kebab (6 Pcs)', price: 'Rs250', image: 'assets/images/food4.jpg'),
          RestaurantDetail(title: 'Paneer Tikka', price: 'Rs200', image: 'assets/images/food3.jpg', desc: 'Grilled cottage cheese with bell peppers'),
        ],
        const [
          RestaurantDetail(title: 'Fish Grill', price: 'Rs280', desc: 'Fresh fish grilled with lemon and herbs'),
          RestaurantDetail(title: 'Lamb Chops', price: 'Rs450', desc: 'Tender lamb chops with mint sauce'),
          RestaurantDetail(title: 'Mushroom Grill', price: 'Rs180'),
        ],
        const [
          RestaurantDetail(title: 'French Fries', price: 'Rs100'),
          RestaurantDetail(title: 'Coleslaw', price: 'Rs60'),
          RestaurantDetail(title: 'Cold Coffee', price: 'Rs90'),
          RestaurantDetail(title: 'Lime Soda', price: 'Rs50'),
        ],
      ],
    },
    'Pizza Corner': {
      'categories': ['Pizzas', 'Pasta & Sides', 'Desserts'],
      'items': [
        const [
          RestaurantDetail(title: 'Margherita Pizza', price: 'Rs199', image: 'assets/images/food8.jpg', desc: 'Classic pizza with mozzarella and basil'),
          RestaurantDetail(title: 'Pepperoni Pizza', price: 'Rs299', image: 'assets/images/food7.jpg', desc: 'Loaded with pepperoni and extra cheese'),
          RestaurantDetail(title: 'Farmhouse Pizza', price: 'Rs269', image: 'assets/images/food5.jpg', desc: 'Fresh veggies with capsicum, onion, tomato'),
          RestaurantDetail(title: 'BBQ Chicken Pizza', price: 'Rs329', desc: 'Smoky BBQ chicken with jalapeños'),
          RestaurantDetail(title: 'Paneer Tikka Pizza', price: 'Rs279', desc: 'Indian fusion with tandoori paneer'),
        ],
        const [
          RestaurantDetail(title: 'Penne Arrabiata', price: 'Rs180', desc: 'Spicy tomato sauce pasta'),
          RestaurantDetail(title: 'Alfredo Pasta', price: 'Rs200', desc: 'Creamy white sauce pasta'),
          RestaurantDetail(title: 'Garlic Bread (4 Pcs)', price: 'Rs120'),
          RestaurantDetail(title: 'Cheesy Fries', price: 'Rs140'),
        ],
        const [
          RestaurantDetail(title: 'Choco Lava Cake', price: 'Rs99', desc: 'Warm chocolate cake with molten center'),
          RestaurantDetail(title: 'Brownie Sundae', price: 'Rs149'),
        ],
      ],
    },
    'Shiva Bhavan': {
      'categories': ['Tiffin Items', 'Meals', 'Snacks'],
      'items': [
        const [
          RestaurantDetail(title: 'Set Dosa (3 Pcs)', price: 'Rs60', image: 'assets/images/food2.jpg', desc: 'Soft spongy dosas served with chutney and sambar'),
          RestaurantDetail(title: 'Pongal', price: 'Rs70', image: 'assets/images/food1.jpg'),
          RestaurantDetail(title: 'Upma', price: 'Rs50', image: 'assets/images/food3.jpg', desc: 'Rava upma with vegetables'),
          RestaurantDetail(title: 'Poori (2 Pcs)', price: 'Rs65', image: 'assets/images/food4.jpg'),
        ],
        const [
          RestaurantDetail(title: 'Veg Meals (Unlimited)', price: 'Rs120', desc: 'Full South Indian meals with rice, sambar, rasam, curd, and more'),
          RestaurantDetail(title: 'Mini Meals', price: 'Rs90', desc: 'Compact meal with rice, sambar and one curry'),
          RestaurantDetail(title: 'Curd Rice', price: 'Rs60'),
        ],
        const [
          RestaurantDetail(title: 'Bajji (5 Pcs)', price: 'Rs50', desc: 'Crispy fried banana or chili bajjis'),
          RestaurantDetail(title: 'Bonda (4 Pcs)', price: 'Rs45'),
          RestaurantDetail(title: 'Vadai (2 Pcs)', price: 'Rs40'),
        ],
      ],
    },
    'BBQ Nation': {
      'categories': ['Starters', 'Main Course', 'Desserts'],
      'items': [
        const [
          RestaurantDetail(title: 'Cajun Spiced Potato', price: 'Rs180', image: 'assets/images/food8.jpg', desc: 'Crispy potatoes with cajun spice blend'),
          RestaurantDetail(title: 'Mushroom Galouti', price: 'Rs220', image: 'assets/images/food7.jpg'),
          RestaurantDetail(title: 'Chicken Wings', price: 'Rs280', image: 'assets/images/food4.jpg', desc: 'Spicy grilled chicken wings'),
          RestaurantDetail(title: 'Fish Tikka', price: 'Rs260', desc: 'Tender fish marinated in Indian spices'),
        ],
        const [
          RestaurantDetail(title: 'Butter Chicken', price: 'Rs320', desc: 'Rich and creamy tomato-based chicken curry'),
          RestaurantDetail(title: 'Dal Makhani', price: 'Rs200', desc: 'Slow-cooked black lentils in butter and cream'),
          RestaurantDetail(title: 'Veg Kolhapuri', price: 'Rs180'),
          RestaurantDetail(title: 'Biryani', price: 'Rs250'),
        ],
        const [
          RestaurantDetail(title: 'Gulab Jamun', price: 'Rs80'),
          RestaurantDetail(title: 'Live Ice Cream Counter', price: 'Rs120', desc: 'Made fresh at the table with your choice of toppings'),
          RestaurantDetail(title: 'Phirni', price: 'Rs90'),
        ],
      ],
    },
    'Dinner Expresss': {
      'categories': ['Dinner Specials', 'Curries', 'Rice & Breads'],
      'items': [
        const [
          RestaurantDetail(title: 'Butter Chicken', price: 'Rs250', image: 'assets/images/food4.jpg', desc: 'Creamy tomato-based chicken curry'),
          RestaurantDetail(title: 'Kadai Paneer', price: 'Rs200', image: 'assets/images/food3.jpg', desc: 'Paneer with bell peppers in spicy gravy'),
          RestaurantDetail(title: 'Chicken Tikka Masala', price: 'Rs270', image: 'assets/images/food7.jpg'),
          RestaurantDetail(title: 'Fish Curry', price: 'Rs260', desc: 'Coastal style fish curry'),
        ],
        const [
          RestaurantDetail(title: 'Palak Paneer', price: 'Rs180', desc: 'Spinach and cottage cheese curry'),
          RestaurantDetail(title: 'Chole Bhature', price: 'Rs130'),
          RestaurantDetail(title: 'Malai Kofta', price: 'Rs200', desc: 'Creamy gravy with cheese dumplings'),
        ],
        const [
          RestaurantDetail(title: 'Veg Pulao', price: 'Rs120'),
          RestaurantDetail(title: 'Butter Naan', price: 'Rs40'),
          RestaurantDetail(title: 'Tandoori Roti', price: 'Rs30'),
          RestaurantDetail(title: 'Laccha Paratha', price: 'Rs50'),
        ],
      ],
    },
    'Parota King': {
      'categories': ['Parotta Varieties', 'Side Dishes', 'Specials'],
      'items': [
        const [
          RestaurantDetail(title: 'Plain Parotta', price: 'Rs20', image: 'assets/images/food5.jpg', desc: 'Flaky layered Kerala parotta'),
          RestaurantDetail(title: 'Coin Parotta', price: 'Rs60', image: 'assets/images/food1.jpg', desc: 'Bite-sized crispy parottas'),
          RestaurantDetail(title: 'Egg Parotta', price: 'Rs50', image: 'assets/images/food2.jpg'),
          RestaurantDetail(title: 'Kothu Parotta', price: 'Rs80', image: 'assets/images/food4.jpg', desc: 'Shredded parotta tossed with egg and spices'),
          RestaurantDetail(title: 'Chilli Parotta', price: 'Rs90', desc: 'Spicy parotta with onions and sauces'),
        ],
        const [
          RestaurantDetail(title: 'Chicken Curry', price: 'Rs150', desc: 'Spicy chicken curry perfect with parotta'),
          RestaurantDetail(title: 'Mutton Curry', price: 'Rs200'),
          RestaurantDetail(title: 'Egg Curry', price: 'Rs80'),
          RestaurantDetail(title: 'Veg Kurma', price: 'Rs100', desc: 'Mild coconut-based vegetable curry'),
        ],
        const [
          RestaurantDetail(title: 'Chicken Kothu Parotta', price: 'Rs120', desc: 'Shredded parotta with chicken'),
          RestaurantDetail(title: 'Sri Lankan Parotta Set', price: 'Rs160'),
        ],
      ],
    },
    'Murugan Idly': {
      'categories': ['Idly Shop Specials', 'Dosas', 'Beverages'],
      'items': [
        const [
          RestaurantDetail(title: 'Soft Idly (3 Pcs)', price: 'Rs45', image: 'assets/images/food2.jpg', desc: 'Melt-in-mouth idlis with signature sambar'),
          RestaurantDetail(title: 'Ghee Pongal', price: 'Rs75', image: 'assets/images/food1.jpg'),
          RestaurantDetail(title: 'Mini Idly Sambar', price: 'Rs65', image: 'assets/images/food6.jpg', desc: 'Bite-sized idlis dunked in aromatic sambar'),
          RestaurantDetail(title: 'Kuzhi Paniyaram', price: 'Rs55', image: 'assets/images/food3.jpg'),
        ],
        const [
          RestaurantDetail(title: 'Crispy Ghee Roast', price: 'Rs85', desc: 'Golden crispy dosa with ghee'),
          RestaurantDetail(title: 'Masala Dosa', price: 'Rs80', desc: 'Classic masala dosa with potato filling'),
          RestaurantDetail(title: 'Rava Dosa', price: 'Rs75'),
        ],
        const [
          RestaurantDetail(title: 'Filter Coffee', price: 'Rs30', desc: 'Authentic South Indian filter coffee'),
          RestaurantDetail(title: 'Badam Milk', price: 'Rs50'),
          RestaurantDetail(title: 'Buttermilk', price: 'Rs25'),
        ],
      ],
    },
    'Adyar Hotel': {
      'categories': ['Meals', 'Tiffin', 'Snacks'],
      'items': [
        const [
          RestaurantDetail(title: 'Full Meals', price: 'Rs130', image: 'assets/images/food6.jpg', desc: 'Traditional South Indian thali with unlimited servings'),
          RestaurantDetail(title: 'Sambar Rice', price: 'Rs80', image: 'assets/images/food1.jpg'),
          RestaurantDetail(title: 'Curd Rice', price: 'Rs70', image: 'assets/images/food3.jpg', desc: 'Cool tempered curd rice'),
          RestaurantDetail(title: 'Lemon Rice', price: 'Rs75'),
        ],
        const [
          RestaurantDetail(title: 'Masala Dosa', price: 'Rs75', desc: 'Classic masala dosa'),
          RestaurantDetail(title: 'Rava Dosa', price: 'Rs70'),
          RestaurantDetail(title: 'Pongal', price: 'Rs65'),
        ],
        const [
          RestaurantDetail(title: 'Medhu Vadai', price: 'Rs30'),
          RestaurantDetail(title: 'Samosa (2 Pcs)', price: 'Rs40'),
          RestaurantDetail(title: 'Sweet Bonda', price: 'Rs35'),
        ],
      ],
    },
    'Mass Hotel': {
      'categories': ['Non-Veg Specials', 'Biryani', 'Sides'],
      'items': [
        const [
          RestaurantDetail(title: 'Chicken Fry', price: 'Rs180', image: 'assets/images/food6.jpg', desc: 'Crispy South Indian style fried chicken'),
          RestaurantDetail(title: 'Mutton Chukka', price: 'Rs250', image: 'assets/images/food7.jpg', desc: 'Dry mutton fry with Indian spices'),
          RestaurantDetail(title: 'Fish Fry', price: 'Rs160', image: 'assets/images/food8.jpg'),
          RestaurantDetail(title: 'Egg Podimas', price: 'Rs70', desc: 'Scrambled eggs with onions and spices'),
        ],
        const [
          RestaurantDetail(title: 'Chicken Biryani', price: 'Rs160', desc: 'Fragrant rice with tender chicken'),
          RestaurantDetail(title: 'Mutton Biryani', price: 'Rs220'),
          RestaurantDetail(title: 'Egg Biryani', price: 'Rs120'),
        ],
        const [
          RestaurantDetail(title: 'Raita', price: 'Rs30'),
          RestaurantDetail(title: 'Brinjal Curry', price: 'Rs50'),
          RestaurantDetail(title: 'Appalam', price: 'Rs10'),
        ],
      ],
    },
    'Mumbai Mirchi': {
      'categories': ['Street Food', 'Main Course', 'Drinks'],
      'items': [
        const [
          RestaurantDetail(title: 'Pav Bhaji', price: 'Rs120', image: 'assets/images/food7.jpg', desc: 'Mumbai style spicy mashed vegetable curry with butter pav'),
          RestaurantDetail(title: 'Vada Pav', price: 'Rs40', image: 'assets/images/food5.jpg', desc: 'The Mumbai burger! Spicy potato fritter in pav'),
          RestaurantDetail(title: 'Sev Puri (6 Pcs)', price: 'Rs70', image: 'assets/images/food1.jpg'),
          RestaurantDetail(title: 'Bhel Puri', price: 'Rs60', desc: 'Crunchy puffed rice chaat'),
          RestaurantDetail(title: 'Dahi Puri', price: 'Rs80'),
        ],
        const [
          RestaurantDetail(title: 'Misal Pav', price: 'Rs100', desc: 'Spicy sprouted moth bean curry with pav'),
          RestaurantDetail(title: 'Tawa Pulao', price: 'Rs130', desc: 'Mumbai style spicy rice'),
          RestaurantDetail(title: 'Bombay Sandwich', price: 'Rs80'),
        ],
        const [
          RestaurantDetail(title: 'Cutting Chai', price: 'Rs20'),
          RestaurantDetail(title: 'Mango Lassi', price: 'Rs70'),
          RestaurantDetail(title: 'Kokum Sharbat', price: 'Rs50', desc: 'Refreshing kokum drink'),
        ],
      ],
    },
    'Chai Truck': {
      'categories': ['Hot Beverages', 'Cold Beverages', 'Snacks'],
      'items': [
        const [
          RestaurantDetail(title: 'Masala Chai', price: 'Rs30', image: 'assets/images/food1.jpg', desc: 'Aromatic spiced tea'),
          RestaurantDetail(title: 'Ginger Tea', price: 'Rs35', image: 'assets/images/food5.jpg'),
          RestaurantDetail(title: 'Cardamom Tea', price: 'Rs35'),
          RestaurantDetail(title: 'Kulhad Chai', price: 'Rs40', desc: 'Tea served in traditional clay pot'),
          RestaurantDetail(title: 'Green Tea', price: 'Rs45'),
        ],
        const [
          RestaurantDetail(title: 'Iced Tea', price: 'Rs60', desc: 'Refreshing cold tea with lemon'),
          RestaurantDetail(title: 'Cold Coffee', price: 'Rs80'),
          RestaurantDetail(title: 'Mango Shake', price: 'Rs90'),
        ],
        const [
          RestaurantDetail(title: 'Bun Maska', price: 'Rs40', desc: 'Soft bun with butter - perfect with chai'),
          RestaurantDetail(title: 'Khari Biscuit', price: 'Rs30'),
          RestaurantDetail(title: 'Samosa', price: 'Rs20'),
        ],
      ],
    },
    'Veg King': {
      'categories': ['Paneer Specials', 'Rice & Breads', 'Thalis'],
      'items': [
        const [
          RestaurantDetail(title: 'Paneer Butter Masala', price: 'Rs180', image: 'assets/images/food5.jpg', desc: 'Rich tomato gravy with soft paneer'),
          RestaurantDetail(title: 'Shahi Paneer', price: 'Rs200', image: 'assets/images/food3.jpg'),
          RestaurantDetail(title: 'Paneer Do Pyaza', price: 'Rs190', desc: 'Paneer with double onion gravy'),
          RestaurantDetail(title: 'Matar Paneer', price: 'Rs170'),
        ],
        const [
          RestaurantDetail(title: 'Veg Pulao', price: 'Rs110', desc: 'Fragrant rice with vegetables'),
          RestaurantDetail(title: 'Butter Naan', price: 'Rs35'),
          RestaurantDetail(title: 'Missi Roti', price: 'Rs40'),
          RestaurantDetail(title: 'Jeera Rice', price: 'Rs90'),
        ],
        const [
          RestaurantDetail(title: 'Veg Thali', price: 'Rs160', desc: 'Complete North Indian thali with 2 curries, dal, rice, roti, and dessert'),
          RestaurantDetail(title: 'Mini Thali', price: 'Rs110'),
        ],
      ],
    },
    'Chennai Mirchi': {
      'categories': ['Chettinad Specials', 'Tandoor', 'Rice Bowl'],
      'items': [
        const [
          RestaurantDetail(title: 'Chettinad Chicken', price: 'Rs220', image: 'assets/images/food7.jpg', desc: 'Fiery chicken curry with roasted spices'),
          RestaurantDetail(title: 'Pepper Mutton', price: 'Rs280', image: 'assets/images/food8.jpg'),
          RestaurantDetail(title: 'Nattu Kozhi Fry', price: 'Rs260', desc: 'Country chicken fry'),
          RestaurantDetail(title: 'Prawn Masala', price: 'Rs300'),
        ],
        const [
          RestaurantDetail(title: 'Tandoori Chicken Half', price: 'Rs220', desc: 'Clay oven roasted chicken'),
          RestaurantDetail(title: 'Chicken Tikka', price: 'Rs200'),
          RestaurantDetail(title: 'Reshmi Kebab', price: 'Rs240'),
        ],
        const [
          RestaurantDetail(title: 'Chicken Rice Bowl', price: 'Rs150', desc: 'Spiced rice with chicken curry'),
          RestaurantDetail(title: 'Egg Rice Bowl', price: 'Rs100'),
        ],
      ],
    },
  };
}
