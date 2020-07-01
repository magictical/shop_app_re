import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              // send arguments to detial screen
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          // 특정 위젯의 하위 위젯과 같이 리빌드되어야 할 경우 적용
          // 전체는 리빌드는 일반적인 Provider.of<dynamic>(context); 문법사용
          leading: Consumer<Product>(
            // productItem은 Provider<Product>의 파라메터이기 때문에 isFavorite를 참조가능!
            builder: (ctx, productItem, _) => IconButton(
              icon: Icon(
                productItem.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: () {
                productItem.togglefavoriteStatus(
                  authData.token,
                  authData.userId,
                );
              },
              color: Theme.of(context).accentColor,
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              // hide previous snackbar immediately
              Scaffold.of(context).hideCurrentSnackBar();
              // show snackbar after onPressed
              // Scaffold.of.(context) 는 직접 연결된 최상위의 Scaffold의 정보를 참조한다.
              // 최상위 Scaffold에 drawer가 사용된다면 여기서 사용할 수 있는 원리다.
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Added item to cart!',
                ),
                duration: Duration(seconds: 3),
                action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    }),
              ));
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
