import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_shop/Store/category_products.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:e_shop/Models/item.dart';
import 'package:flutter/material.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:provider/provider.dart';
import 'package:e_shop/Data/shopping_cart.dart';

class ProductPage extends StatefulWidget {
  final ItemModel itemModel;
  ProductPage({
    this.itemModel,
  });
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int quantityOfItems = 1;
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          leadingWidget: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Route route = MaterialPageRoute(
                builder: (context) => CategoryProducts(),
              );
              Navigator.pushReplacement(
                context,
                route,
              );
            },
          ),
        ),
        drawer: MyDrawer(),
        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(
                8.0,
              ),
              width: screenSize.width,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: CachedNetworkImage(
                          imageUrl: widget.itemModel.thumbnailUrl,
                          placeholder: (context, url) => circularProgress(),
                          errorWidget: (context, url, error) => Icon(
                            Icons.error,
                          ),
                        ), /*Image.network(
                          widget.itemModel.thumbnailUrl,
                        ),*/
                      ),
                      Container(
                        color: Colors.grey[300],
                        child: SizedBox(
                          height: 1.0,
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(
                      20.0,
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.itemModel.title,
                            style: boldTextStyle,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            widget.itemModel.longDescription,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          if (widget.itemModel.discount == 0 ||
                              widget.itemModel.discount == null) ...[
                            Text(
                              "\$ " + widget.itemModel.price.toString(),
                              style: boldTextStyle,
                            ),
                          ],
                          if (widget.itemModel.discount > 0 &&
                              widget.itemModel.discount != null) ...[
                            Row(
                              children: [
                                Text(
                                  "\$ " + widget.itemModel.price.toString(),
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Text(
                                  "\$ " +
                                      discountedPrice(
                                        price: widget.itemModel.price,
                                        discount: widget.itemModel.discount,
                                      ).toString(),
                                  style: boldTextStyle,
                                ),
                              ],
                            ),
                          ],
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8.0,
                    ),
                    child: Center(
                      child: !Provider.of<ShoppingCart>(context)
                              .isInCart(itemModelCheck: widget.itemModel)
                          ? InkWell(
                              onTap: () {
                                addItemModelToCart(
                                  context: context,
                                  itemModel: widget.itemModel,
                                );
                              },
                              child: Container(
                                decoration: new BoxDecoration(
                                  color: Colors.lightGreenAccent,
                                ),
                                width: screenSize.width - 40.0,
                                height: 50.0,
                                child: Center(
                                  child: Text(
                                    "Agregar al carrito",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                modifyQuantity(
                                  context: context,
                                  itemModelModify:
                                      Provider.of<ShoppingCart>(context)
                                          .getItemModel(
                                              itemModelCheck: widget.itemModel),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const boldTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
const largeTextStyle = TextStyle(fontWeight: FontWeight.normal, fontSize: 20);
