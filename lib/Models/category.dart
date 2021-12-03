import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Config/config.dart';

final categoriesRef = EcommerceApp.firestore.collection(
  EcommerceApp.collectionCategories,
);

class CategoryElement {
  final String uid;
  final List<String> searchTerms;
  String name;
  String subtitle;
  int cuenta;
  String img;
  String centro;

  CategoryElement({
    this.subtitle,
    this.searchTerms,
    this.cuenta,
    this.img,
    this.name,
    this.uid,
    this.centro,
  });

  factory CategoryElement.fromDocument({DocumentSnapshot doc}) {
    List<String> searchTerms = [];

    if ((doc.data() as Map)['searchTerms'] != null) {
      for (String term in (doc.data() as Map)['searchTerms']) {
        searchTerms.add(
          term,
        );
      }
    }

    CategoryElement categoryElement = CategoryElement(
      subtitle: (doc.data() as Map)['subtitle'] != null
          ? (doc.data() as Map)['subtitle']
          : null,
      searchTerms: searchTerms,
      uid: doc.id != null ? doc.id : null,
      cuenta: (doc.data() as Map)['cuenta'] != null
          ? (doc.data() as Map)['cuenta']
          : null,
      img: (doc.data() as Map)['img'] != null
          ? (doc.data() as Map)['img']
          : null,
      name: (doc.data() as Map)['name'] != null
          ? (doc.data() as Map)['name']
          : null,
      centro: (doc.data() as Map)['centro'] != null
          ? (doc.data() as Map)['centro']
          : null,
    );

    return categoryElement;
  }

  Future<void> addCount() async {
    this.cuenta++;
    await categoriesRef.doc(this.uid).update({
      'cuenta': this.cuenta,
    });
  }
}
