import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Models/item.dart';
import 'package:e_shop/Store/category_products.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Widgets/customAppBar.dart';

class SearchProduct extends StatefulWidget {
  @override
  _SearchProductState createState() => new _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  QuerySnapshot docList;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          leadingWidget: IconButton(
            icon: Icon(
              Icons.chevron_left,
            ),
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
          bottom: PreferredSize(
            child: searchWidget(),
            preferredSize: Size(
              56.0,
              56.0,
            ),
          ),
        ),
        body: docList != null && docList.docs.length > 0
            ? ListView.builder(
                itemCount: docList.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  ItemModel model = ItemModel.fromJson(
                    docList.docs[index].data(),
                    docList.docs[index].id,
                  );

                  return sourceInfo(
                    model: model,
                    context: context,
                  );
                },
              )
            : Text(
                "No se encontraron resultados",
              ),
      ),
    );
  }

  Container searchWidget() {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: 80.0,
      decoration: new BoxDecoration(
        color: Colors.lightGreenAccent,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width - 40.0,
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
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 8.0,
                ),
                child: TextField(
                  onChanged: (String value) async {
                    await startSearching(value);
                  },
                  decoration: InputDecoration.collapsed(
                    hintText: "Buscar aquí...",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> startSearching(String query) async {
    QuerySnapshot queryReturn = await EcommerceApp.firestore
        .collection("items")
        .where('searchTerms', arrayContains: query)
        .get();
    setState(() {
      docList = queryReturn;
    });
  }
}

/*Widget buildResultCard(data) {
  return Card();
}*/
