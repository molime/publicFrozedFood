import 'package:e_shop/Data/category_data.dart';
import 'package:e_shop/Models/category.dart';
import 'package:e_shop/Store/category_products.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class CategoryItem extends StatelessWidget {
  final CategoryElement categoryElement;
  final double width;
  final double height;

  CategoryItem({
    Key key,
    @required this.categoryElement,
    @required this.width,
    @required this.height,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: GestureDetector(
        onTap: () {
          Provider.of<CategoryData>(context, listen: false)
              .setCategory(categoryElement: categoryElement);
          Route route = MaterialPageRoute(
            builder: (context) => CategoryProducts(),
          );
          Navigator.pushReplacement(
            context,
            route,
          );
        },
        child: GridTile(
          child: CachedNetworkImage(
            imageUrl: categoryElement.img,
            placeholder: (context, url) => circularProgress(),
            errorWidget: (context, url, error) => Icon(
              Icons.error,
            ),
            fit: BoxFit.fitWidth,
          ),
          /*Image.network(
            categoryElement.img,
            fit: BoxFit.fitWidth,
          ),*/
          footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: Text(
              categoryElement.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
    /*Stack(
      children: [
        SizedBox(
          width: width * 0.4,
          height: height * 0.4,
          child: GestureDetector(
            onTap: () async {
              Provider.of<CategoryData>(context, listen: false)
                  .setCategory(categoryElement: categoryElement);
              Route route = MaterialPageRoute(
                builder: (context) => CategoryProducts(),
              );
              Navigator.pushReplacement(
                context,
                route,
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 5.0,
                vertical: 5.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xffa29aac),
                      blurRadius: 10.0,
                      spreadRadius: 1.0,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: categoryElement.img,
                      width: 42,
                      placeholder: (context, url) => circularProgress(),
                      errorWidget: (context, url, error) => Icon(
                        Icons.error,
                      ),
                    ),
                    */ /*Image.network(
                      categoryElement.img,
                      width: 42,
                    ),*/ /*
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      categoryElement.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      categoryElement.subtitle,
                      style: TextStyle(
                        color: Color(0xffa29aac),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    */ /*Text(
                      '${categoryElement.cuenta} artículos',
                      style: TextStyle(
                        color: Color(0xffa29aac),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),*/ /*
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );*/
  }
}
