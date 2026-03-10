import 'package:flutter/material.dart';
import 'package:swiggy_ui/models/spotlight_best_top_food.dart';
import 'package:swiggy_ui/utils/app_colors.dart';
import 'package:swiggy_ui/utils/ui_helper.dart';
import 'package:swiggy_ui/widgets/custom_divider_view.dart';
import 'package:swiggy_ui/widgets/mobile/search_food_list_item_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _searchQuery = '';
  String _sortBy = 'none';
  final _allRestaurants = <SpotlightBestTopFood>[
    ...SpotlightBestTopFood.getPopularAllRestaurants(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  List<SpotlightBestTopFood> get _filteredRestaurants {
    var list = [..._allRestaurants];

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      list = list.where((r) {
        return r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            r.desc.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            r.coupon.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'rating':
        list.sort((a, b) {
          final ra = _extractRating(a.ratingTimePrice);
          final rb = _extractRating(b.ratingTimePrice);
          return rb.compareTo(ra);
        });
        break;
      case 'time':
        list.sort((a, b) {
          final ta = _extractTime(a.ratingTimePrice);
          final tb = _extractTime(b.ratingTimePrice);
          return ta.compareTo(tb);
        });
        break;
      case 'price_low':
        list.sort((a, b) {
          final pa = _extractPrice(a.ratingTimePrice);
          final pb = _extractPrice(b.ratingTimePrice);
          return pa.compareTo(pb);
        });
        break;
      case 'price_high':
        list.sort((a, b) {
          final pa = _extractPrice(a.ratingTimePrice);
          final pb = _extractPrice(b.ratingTimePrice);
          return pb.compareTo(pa);
        });
        break;
      case 'name':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return list;
  }

  double _extractRating(String rtp) {
    final match = RegExp(r'(\d+\.?\d*)').firstMatch(rtp);
    return match != null ? double.parse(match.group(1)!) : 0;
  }

  int _extractTime(String rtp) {
    final match = RegExp(r'(\d+)\s*mins').firstMatch(rtp);
    return match != null ? int.parse(match.group(1)!) : 60;
  }

  int _extractPrice(String rtp) {
    final match = RegExp(r'Rs\s*(\d+)').firstMatch(rtp);
    return match != null ? int.parse(match.group(1)!) : 999;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRestaurants;

    return Scaffold(
      backgroundColor: Colors.cyan[100],
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Search bar
              Container(
                padding:
                    const EdgeInsets.only(left: 15.0, top: 2.0, bottom: 2.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search for restaurants and food',
                          hintStyle:
                              Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Colors.grey,
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                        },
                      ),
                    UIHelper.horizontalSpaceSmall(),
                    const Icon(Icons.search, color: Colors.deepOrange),
                    UIHelper.horizontalSpaceSmall(),
                  ],
                ),
              ),
              UIHelper.verticalSpaceSmall(),
              // Sort & Filter row
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSortChip('⭐ Rating', 'rating'),
                    _buildSortChip('⚡ Fast Delivery', 'time'),
                    _buildSortChip('💰 Price: Low', 'price_low'),
                    _buildSortChip('💎 Price: High', 'price_high'),
                    _buildSortChip('🔤 Name', 'name'),
                  ],
                ),
              ),
              UIHelper.verticalSpaceExtraSmall(),
              // Tabs
              TabBar(
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.black,
                controller: _tabController,
                indicatorColor: darkOrange,
                labelStyle: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontSize: 18.0, color: darkOrange),
                unselectedLabelStyle:
                    Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontSize: 18.0,
                          color: Colors.grey[200],
                        ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(child: Text('Restaurant (${filtered.length})')),
                  Tab(child: Text('Dishes (${filtered.length})')),
                ],
              ),
              UIHelper.verticalSpaceSmall(),
              const CustomDividerView(dividerHeight: 8.0),
              // Results
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 60, color: Colors.grey[400]),
                            UIHelper.verticalSpaceMedium(),
                            Text(
                              'No results for "$_searchQuery"',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSearchList(filtered),
                          _buildSearchList(filtered),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isActive = _sortBy == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isActive,
        selectedColor: Colors.deepOrange,
        backgroundColor: Colors.white,
        checkmarkColor: Colors.white,
        side: BorderSide(
            color: isActive ? Colors.deepOrange : Colors.grey.shade300),
        onSelected: (selected) {
          setState(() {
            _sortBy = selected ? value : 'none';
          });
        },
      ),
    );
  }

  Widget _buildSearchList(List<SpotlightBestTopFood> items) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) => SearchFoodListItemView(
        food: items[index],
      ),
    );
  }
}
