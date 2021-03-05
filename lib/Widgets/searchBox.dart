import 'package:e_shop/Data/category_data.dart';
import 'package:e_shop/Store/search_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Store/Search.dart';

class SearchBoxDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      InkWell(
        onTap: () {
          Route route = MaterialPageRoute(
            builder: (context) => SearchProduct(),
          );
          Navigator.pushReplacement(context, route);
        },
        child: Container(
          decoration: new BoxDecoration(
            color: Colors.lightGreenAccent,
          ),
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: 80.0,
          child: InkWell(
            child: Container(
              margin: EdgeInsets.only(
                left: 10.0,
                right: 10.0,
              ),
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  6.0,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 8.0,
                    ),
                    child: Icon(
                      Icons.search,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 8.0,
                    ),
                    child: Text(
                      "Buscar",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

class SearchBoxCategoryDelegate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: Provider.of<CategoryData>(context).categories.length > 0
          ? () {
              Route route = MaterialPageRoute(
                builder: (context) => SearchCategory(),
              );
              Navigator.pushReplacement(context, route);
            }
          : () {},
      child: Container(
        decoration: new BoxDecoration(
          color: Colors.lightGreenAccent,
        ),
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: 80.0,
        child: InkWell(
          child: Container(
            margin: EdgeInsets.only(
              left: 10.0,
              right: 10.0,
            ),
            width: MediaQuery.of(context).size.width,
            height: 50.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                6.0,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 8.0,
                  ),
                  child: Icon(
                    Icons.search,
                    color: Colors.blueGrey,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 8.0,
                  ),
                  child: Text(
                    "Buscar",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*class SearchBoxCategoryDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      InkWell(
        onTap: Provider.of<CategoryData>(context).categories.length > 0
            ? () {
                Route route = MaterialPageRoute(
                  builder: (context) => SearchCategory(),
                );
                Navigator.pushReplacement(context, route);
              }
            : () {},
        child: Container(
          decoration: new BoxDecoration(
            color: Colors.lightGreenAccent,
          ),
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: 80.0,
          child: InkWell(
            child: Container(
              margin: EdgeInsets.only(
                left: 10.0,
                right: 10.0,
              ),
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  6.0,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 8.0,
                    ),
                    child: Icon(
                      Icons.search,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 8.0,
                    ),
                    child: Text(
                      "Buscar",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}*/
