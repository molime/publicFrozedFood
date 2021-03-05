import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Data/category_data.dart';
import 'package:e_shop/Models/category.dart';
import 'package:e_shop/Models/item.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/categoryItem.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../Widgets/customAppBar.dart';

class SearchCategory extends StatefulWidget {
  @override
  _SearchCategoryState createState() => new _SearchCategoryState();
}

class _SearchCategoryState extends State<SearchCategory> {
  List<CategoryElement> docList = [];
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
                builder: (context) => StoreHome(),
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
        body: docList != null && docList.length > 0
            ? GridView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: docList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1.0,
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return CategoryItem(
                    categoryElement: docList[index],
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
                    await startSearchingCategories(value);
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

  Future<void> startSearchingCategories(String query) async {
    List<CategoryElement> listCats =
        Provider.of<CategoryData>(context, listen: false)
            .categories
            .where(
              (element) => element.searchTerms.contains(
                query,
              ),
            )
            .toList();
    setState(() {
      docList = listCats;
    });
  }
}

/*Widget buildResultCard(data) {
  return Card();
}*/
