import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class CartScreen extends StatelessWidget {
  final List<Product> cart;

  CartScreen({required this.cart});

  double get total {
    return cart.fold(0, (sum, item) => sum + item.price);
  }

  Future<void> clearCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');
    cart.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(cart[i].name),
                trailing: Text("\$${cart[i].price.toStringAsFixed(2)}"),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total: \$${total.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 18)),
                ElevatedButton(
                  child: Text("Place Order"),
                  onPressed: () async {
                    await clearCart();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Order Placed!")));
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
