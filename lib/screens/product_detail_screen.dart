import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const String routeName = '/product_detail_screen';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    /* listen: false 일 경우 첫 rebuild 에서 provider의 값을 가져오고
    이후에는 비활성화 이기 때문에 rebuild하더라도 업데이트 하지 않음
    데이터의 업데이트가 필요 없는 경우 첫 로드에만 사용하면 좋을 듯 하다. 
    */
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
    );
  }
}
