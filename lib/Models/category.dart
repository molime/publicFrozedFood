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

    if (doc.data()['searchTerms'] != null) {
      for (String term in doc.data()['searchTerms']) {
        searchTerms.add(
          term,
        );
      }
    }

    CategoryElement categoryElement = CategoryElement(
      subtitle: doc.data()['subtitle'] != null ? doc.data()['subtitle'] : null,
      searchTerms: searchTerms,
      uid: doc.id != null ? doc.id : null,
      cuenta: doc.data()['cuenta'] != null ? doc.data()['cuenta'] : null,
      img: doc.data()['img'] != null ? doc.data()['img'] : null,
      name: doc.data()['name'] != null ? doc.data()['name'] : null,
      centro: doc.data()['centro'] != null ? doc.data()['centro'] : null,
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
