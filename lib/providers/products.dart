import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String authTokens;

  final String userId;

  Products(this.authTokens, this.userId, this._items);

  var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((item) => item.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoriteOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  /* 데이터가 변경될때만 notifyListeners를 연결해서 데이터의
  변경을 바로 반경하도록 한다. 
  */

  Future<void> fetchAndProducts([bool filterByUser = false]) async {
    final filteredUrl =
        filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        // url선에서 userId 노드만 탐색함 전체 노드를 탐색해서 서버부하를 줄임
        // firebase rule에서 index할 수 있도록 해당 노드를 지정 해줘야함
        'https://flutter-shop-app-adf19.firebaseio.com/products.json?auth=$authTokens$filteredUrl';
    try {
      final response = await http.get(url);
      final extractedata = json.decode(response.body) as Map<String, dynamic>;

      if (extractedata == null) {
        return;
      }
      url =
          'https://flutter-shop-app-adf19.firebaseio.com/userFavorites/$userId.json?auth=$authTokens';
      final favoriteResponse = await http.get(url);
      final favData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedata.forEach((prodId, prodData) {
        loadedProducts.add((Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          // '??' false 부분은 favData[prodId]가 null일 경우 false조건을 준다는것
          isFavorite: favData == null ? false : favData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        )));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProducts(Product product) async {
    final url =
        'https://flutter-shop-app-adf19.firebaseio.com/products.json?auth=$authTokens';
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          }));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-shop-app-adf19.firebaseio.com/products/$id.json?auth=$authTokens';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('error no product id found');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-shop-app-adf19.firebaseio.com/products/$id.json?auth=$authTokens';
    final existingProductIdex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIdex];
    final response = await http.delete(url);
    _items.removeAt(existingProductIdex);
    notifyListeners();
    if (response.statusCode >= 400) {
      _items.insert(existingProductIdex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }

    existingProduct = null;
  }
}
