import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../widgets/product_item.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [
    Product(id: 'p1', name: 'Apple', price: 1.5),
    Product(id: 'p2', name: 'Banana', price: 0.8),
    Product(id: 'p3', name: 'Orange', price: 1.2),
  ];

  List<Product> cart = [];

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  // Load cart from SharedPreferences
  Future<void> loadCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cartData = prefs.getStringList('cart');
    if (cartData != null) {
      setState(() {
        cart = cartData.map((item) => Product.fromJson(item)).toList();
      });
    }
  }

  // Save cart to SharedPreferences
  Future<void> saveCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartData = cart.map((item) => item.toJson()).toList();
    await prefs.setStringList('cart', cartData);
  }

  void addToCart(Product product) {
    setState(() {
      cart.add(product);
    });
    saveCart();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("${product.name} added to cart")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping App'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(cart: cart),
                ),
              );
              loadCart(); // reload cart after returning
            },
          ),
        ],
      ),
      body: ListView(
        children: products
            .map((prod) => ProductItem(
                  product: prod,
                  onAddToCart: () => addToCart(prod),
                ))
            .toList(),
      ),
    );
  }
}
