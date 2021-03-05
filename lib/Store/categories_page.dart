import 'package:e_shop/Data/category_data.dart';
import 'package:e_shop/Widgets/categoryItem.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/Widgets/searchBox.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SearchBoxCategoryDelegate(),
        SizedBox(
          height: 50,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Categorías",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Container(
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: [
              Provider.of<CategoryData>(context).showLoadingCategories()
                  ? circularProgress()
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 11.0,
                        vertical: 11.0,
                      ),
                      child: GridView.builder(
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: Provider.of<CategoryData>(context)
                            .categories
                            .length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 1.0,
                          crossAxisCount: 2,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return CategoryItem(
                            categoryElement: Provider.of<CategoryData>(context)
                                .categories[index],
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
