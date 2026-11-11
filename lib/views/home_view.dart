import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jhyapp/app/app_routes.dart';
import 'package:jhyapp/constants/colors.dart';
import 'package:jhyapp/constants/logos.dart';
import 'package:jhyapp/constants/textstyle.dart';
import 'package:jhyapp/services/drink_service.dart';
import 'package:sizer/sizer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Map<String, dynamic>> _recentDrinks = [];
  bool _isLoadingRecentDrinks = true;
  String? _recentDrinksError;

  final List<Beer> trendingBeers = const [
    Beer(
      'Octoberfest (2026)',
      'Festbier/Weisbier | 6%',
      'Sierra Nevada Brewing Co.',
      '3.5',
      '',
    ),
    Beer('Premium Pils', 'Premium Pils | 4.9%', 'Bitburger Germany', '3.5', ''),
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentDrinks();
  }

  Future<void> _loadRecentDrinks() async {
    setState(() {
      _isLoadingRecentDrinks = true;
      _recentDrinksError = null;
    });

    try {
      final drinks = await DrinkService.getRecentDrinks();
      if (!mounted) return;
      setState(() {
        _recentDrinks = drinks;
        _isLoadingRecentDrinks = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _recentDrinks = [];
        _recentDrinksError = error.toString().replaceFirst('Exception: ', '');
        _isLoadingRecentDrinks = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Good evening', style: subtitleStyle),
          SizedBox(height: 0.8.h),
          Text('Discover', style: headingStyle),
          SizedBox(height: 2.2.h),
          const SearchField(),
          SizedBox(height: 2.5.h),
          const SectionTitle('Trending Beers'),
          SizedBox(height: 1.4.h),
          ...trendingBeers.map(
            (beer) => Padding(
              padding: EdgeInsets.only(bottom: 1.5.h),
              child: BeerTile(beer: beer),
            ),
          ),
          SizedBox(height: 2.1.h),
          const SectionTitle('Recent Activity'),
          SizedBox(height: 1.4.h),
          if (_isLoadingRecentDrinks)
            const Center(child: CircularProgressIndicator())
          else if (_recentDrinksError != null)
            Row(
              children: [
                Expanded(
                  child: Text(_recentDrinksError!, style: subtitleStyle),
                ),
                IconButton(
                  onPressed: _loadRecentDrinks,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Retry',
                ),
              ],
            )
          else if (_recentDrinks.isEmpty)
            Text('No drinks added yet.', style: subtitleStyle)
          else
            ..._recentDrinks.map((drink) {
              final name = drink['name']?.toString() ?? 'Unnamed drink';
              final category = drink['category']?.toString() ?? '';
              final type = drink['type']?.toString() ?? '';
              final abv = drink['abv'];
              final details = [
                if (category.isNotEmpty) category,
                if (abv != null) '$abv%',
                if (type.isNotEmpty)
                  '${type[0].toUpperCase()}${type.substring(1)}',
              ].join(' | ');
              final rating = drink['rating'];

              return Padding(
                padding: EdgeInsets.only(bottom: 1.5.h),
                child: BeerTile(
                  beer: Beer(
                    name,
                    details,
                    drink['brand']?.toString() ?? '',
                    rating?.toString() ?? '-',
                    drink['photo_url']?.toString().trim() ?? '',
                  ),
                  onTap: () =>
                      context.push(AppRoutes.drinkDetail, extra: drink),
                ),
              );
            }),
          SizedBox(height: 4.2.h),
          const SectionTitle('Friends'),
          SizedBox(height: 1.4.h),
          const FriendTile(
            initial: 'A',
            name: 'Alex rated Braustubl',
            detail: 'Rich. Absolutely loved it!!',
            rating: '3.5',
          ),
          const FriendTile(
            initial: 'C',
            name: 'Carla rated Gorkha',
            detail: 'Strong and hazy',
            rating: '3.9',
          ),
        ],
      ),
    );
  }
}

class Beer {
  final String name;
  final String style;
  final String brewery;
  final String rating;
  final String imageUrl;

  const Beer(this.name, this.style, this.brewery, this.rating, this.imageUrl);
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Text(title, style: subheadingStyle);
}

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.2.h,
      decoration: BoxDecoration(
        color: tileClr,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Row(
        children: [
          SvgPicture.asset(AppLogos.search, width: 23, height: 23),
          SizedBox(width: 3.w),
          Text('Search beers, breweries...', style: subtitleStyle),
        ],
      ),
    );
  }
}

class BeerTile extends StatelessWidget {
  final Beer beer;
  final VoidCallback? onTap;

  const BeerTile({required this.beer, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tileClr,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          constraints: BoxConstraints(minHeight: 10.5.h),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
          child: Row(
            children: [
              Container(
                width: 14.w,
                height: 7.5.h,
                decoration: BoxDecoration(
                  color: darkblueClr,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: beer.imageUrl.isEmpty
                    ? Center(
                        child: SvgPicture.asset(
                          AppLogos.beer,
                          width: 30,
                          height: 30,
                        ),
                      )
                    : Image.network(
                        beer.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: SvgPicture.asset(
                            AppLogos.beer,
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      beer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                    Text(
                      beer.style,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: subtitleStyle,
                    ),
                    Text(
                      beer.brewery,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: subtitleStyle,
                    ),
                  ],
                ),
              ),
              Rating(rating: beer.rating),
            ],
          ),
        ),
      ),
    );
  }
}

class Rating extends StatelessWidget {
  final String rating;

  const Rating({required this.rating, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(AppLogos.star, width: 15, height: 15),
        SizedBox(width: 1.w),
        Text(
          rating,
          style: subtitleStyle.copyWith(
            color: whiteClr,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class FriendTile extends StatelessWidget {
  final String initial;
  final String name;
  final String detail;
  final String rating;

  const FriendTile({
    required this.initial,
    required this.name,
    required this.detail,
    required this.rating,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.8.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: darkblueClr,
            child: Text(
              initial,
              style: titleStyle.copyWith(color: lightblueClr),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: titleStyle.copyWith(fontSize: 14.5.sp)),
                Text(detail, style: subtitleStyle.copyWith(fontSize: 11.5.sp)),
              ],
            ),
          ),
          Rating(rating: rating),
        ],
      ),
    );
  }
}
