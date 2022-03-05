import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PagintionTest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PagintionTestState();
  }
}

class PagintionTestState extends State<PagintionTest> {
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Product> products = [];

  String searchKey = "all";
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height / 3.5),
        child: Column(
          children: [
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                // color: orangeColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _textController,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            searchKey = "all";
                            paginatorGlobalKey.currentState.changeState(
                              resetState: true,
                              pageLoadFuture: (page) => getProductsPagtion(
                                page: page,
                                context: context,
                                searchKey: searchKey,
                              ),
                            );
                          }
                        },
                        onSaved: (value) {
                          searchKey = value.isEmpty ? "all" : value;
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.search,
                            ),
                            onPressed: () {
                              _formKey.currentState.save();
                              products = [];

                              paginatorGlobalKey.currentState.changeState(
                                resetState: true,
                                pageLoadFuture: (page) => getProductsPagtion(
                                    page: page,
                                    context: context,
                                    searchKey: searchKey),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Paginator.gridView(
        key: paginatorGlobalKey,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: (itemWidth / itemHeight),
        ),
        pageLoadFuture: (page) =>
            getProductsPagtion(page: page, context: context, searchKey: "all"),
        pageItemsGetter: listItemsGetter,
        listItemBuilder: listItemBuilder,
        loadingWidgetBuilder: loadingWidgetMaker,
        errorWidgetBuilder: errorWidgetMaker,
        emptyListWidgetBuilder: emptyListWidgetMaker,
        totalItemsGetter: totalPagesGetter,
        pageErrorChecker: pageErrorChecker,
        scrollPhysics: BouncingScrollPhysics(),
      ),
    );
  }

  List<dynamic> listItemsGetter(productsData) {
    List<Widget> list = [];
    productsData.products.forEach((value) {
      list.add(productHomeCart(context, value));
    });
    return list;
  }

  Widget listItemBuilder(value, int index) {
    print("value ${value}");
    return value;
  }

  Widget loadingWidgetMaker() {
    return Container(
      alignment: Alignment.center,
      height: 160.0,
      child: CircularProgressIndicator(),
    );
  }

  Widget errorWidgetMaker(productsData, retryListener) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(productsData.total.toString()),
        ),
        FlatButton(
          onPressed: retryListener,
          child: Text('حاول مجداد'),
        )
      ],
    );
  }

  Widget emptyListWidgetMaker(productsData) {
    return Center(
      child: Text('لا يوجد منتجات حالياً'),
    );
  }

  int totalPagesGetter(productsData) {
    return productsData.total;
  }

  bool pageErrorChecker(productsData) {
    return productsData.statusCode != 200;
  }
}

class Product {
  final int id;
  final String name;
  final String catId;
  final String comId;
  final String subcategoryId;
  final price;
  final priceUnit;
  final String image;
  final int discount;
  final int maxQunatity;
  final int minQunatity;
  final String description;
  final String unitType;
  final int quantityUnit;
  final int quantityStatus;
  final int total_target;
  final String subUnitType;
  final int status;
  final int waitingStatus;
  final int storeId;

  final int is_only_total; //0 total only  1 total and unit 2 unit only
  final int must_quantity_total;
  final int quantity_info;
  final int quantity_unit_info;
  const Product({
    @required this.id,
    @required this.name,
    @required this.image,
    @required this.price,
    @required this.discount,
    @required this.unitType,
    @required this.priceUnit,
    @required this.description,
    @required this.subcategoryId,
    @required this.catId,
    @required this.comId,
    @required this.quantityUnit,
    @required this.quantityStatus,
    @required this.subUnitType,
    @required this.status,
    @required this.waitingStatus,
    @required this.storeId,
    @required this.is_only_total,
    @required this.must_quantity_total,
    @required this.quantity_info,
    @required this.quantity_unit_info,
    @required this.maxQunatity,
    @required this.minQunatity,
    @required this.total_target,
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      image: json['image'] == null ? "" : json["image"],
      catId: json['category_id'] == null ? 0 : json["category_id"],
      comId: json['company_id'],
      price: json['sp_total_price'],
      priceUnit: json['sp_unit_price'],
      discount: json['discount'] == null ? 0 : json["discount"],
      description: json['description'] == null ? "" : json["description"],
      subcategoryId: json['subcategory_id'],
      unitType: json['unit_type'],
      quantityUnit: json['quantity_unit'],
      quantityStatus: json['quantity_status'],
      subUnitType: json['subunit_type'],
      status: json['status'],
      waitingStatus: json['waiting_status'],
      storeId: json['store_id'] == null ? 0 : json["store_id"],
      is_only_total: json["is_only_total"] == null ? 1 : json["is_only_total"],
      must_quantity_total:
          json["must_quantity_total"] == null ? 0 : json["must_quantity_total"],
      quantity_info:
          json["quantity_info"] == null ? 10 : json["quantity_info"].toInt(),
      quantity_unit_info:
          json["quantity_unit_info"] == null ? 10 : json["quantity_unit_info"],
      maxQunatity: json["max_quantity"] == null ? 10 : json["max_quantity"],
      minQunatity: json["min_quantity"] == null ? 1 : json["min_quantity"],
      total_target:
          json["must_quantity_total"] == null ? 5 : json["must_quantity_total"],
    );
  }
}

class ProductImages {
  final String image_url;

  ProductImages({this.image_url});
  factory ProductImages.fromJson(Map<String, dynamic> json) {
    return ProductImages(
      image_url: json["image_url"],
    );
  }
}

class ProductsData {
  List products;
  int statusCode;
  String errorMessage;
  String next_page_url;
  int total;
  int nItems;

  ProductsData.fromResponse(http.Response response) {
    this.statusCode = response.statusCode;
    var jsonData = json.decode(response.body)["data"]["products"];

    total = json.decode(response.body)["data"]["products"]['total'];

    products = json
        .decode(response.body)["data"]["products"]["data"]
        .map((e) => Product.fromJson(e))
        .toList();

    nItems = products.length;
  }
  ProductsData.fromComapnyJson(http.Response response) {
    this.statusCode = response.statusCode;
    var jsonData = json.decode(response.body)["data"];

    total = json.decode(response.body)['total'];
    next_page_url = json.decode(response.body)["next_page_url"];

    products = json
        .decode(response.body)["data"]
        .map((e) => Product.fromJson(e))
        .toList();

    nItems = products.length;
  }
  ProductsData.withError(String errorMessage) {
    this.errorMessage = errorMessage;
  }
}

Future<ProductsData> getProductsPagtion(
    {@required int page,
    @required BuildContext context,
    @required String searchKey}) async {
  try {
    var url = Uri.parse(
        "https://dashboard.ringo-eg.com/api/productsV1/store/0/user/0/$searchKey?page=${page}");

    http.Response response = await http.get(url);
    ProductsData productsData = ProductsData.fromResponse(response);
    if (searchKey != "all") {
      productsData.products.removeWhere((element) {
        if (element.name.contains(searchKey)) {
          return false;
        } else
          return true;
      });
    }
    return productsData;
  } catch (e) {
    if (e is IOException) {
      return ProductsData.withError('Please check your internet connection.');
    } else {
      print(e.toString());
      return ProductsData.withError('Something went wrong.');
    }
  }
}

GestureDetector productHomeCart(BuildContext context, Product product) {
  return GestureDetector(
    onTap: () {},
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          shadowColor: Colors.grey.withOpacity(1),
          elevation: 4,
          child: Container(
            height: MediaQuery.of(context).size.height / 1.5,
            width: MediaQuery.of(context).size.width / 1.6,
            alignment: Alignment.topRight,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  'https://dashboard.ringo-eg.com/public/uploads/products/${product.image}',
                  //"assets/images/logo.png",
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height / 6,
                  width: double.infinity,
                ),
                SizedBox(
                  height: 3,
                ),
                Divider(
                  color: Colors.grey,
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Column(
                        //crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            product.name.split(" ").length == 1
                                ? product.name
                                : product.name.split(" ")[0] +
                                    " " +
                                    product.name.split(" ")[1],
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'hanimation'),
                          ),
                          Text(
                            product.description == null
                                ? "غير متاح حالياً"
                                : product.description,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'hanimation',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                " الكمية  : ",
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'hanimation'),
                              ),
                              Text(
                                "${product.unitType} ${product.quantityUnit} ${product.subUnitType}",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'hanimation'),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "السعر جملة: ",
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'hanimation'),
                              ),
                              Text(
                                "${product.price} جنية  ",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'hanimation'),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "السعر قطاعي: ",
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'hanimation'),
                              ),
                              Text(
                                "${product.priceUnit} جنيه",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'hanimation'),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey,
                                onPrimary: Colors.red,
                                shadowColor: Colors.red,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0)),
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 50),
                              ),
                              onPressed: () {},
                              child: Text(
                                "فى أنتظار التفعيل",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
