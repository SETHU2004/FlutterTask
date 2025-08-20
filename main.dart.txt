import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

// Model for cart item
class CartItem {
  final String name;
  final double price;
  int quantity;

  CartItem({required this.name, required this.price, this.quantity = 1});

  // Convert CartItem to JSON
  Map<String, dynamic> toJson() => {'name': name, 'price': price, 'quantity': quantity};

  // Create CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    name: json['name'],
    price: json['price'],
    quantity: json['quantity'],
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<CartItem> products = [
    CartItem(name: "Apple", price: 2.5),
    CartItem(name: "Banana", price: 1.0),
    CartItem(name: "Orange", price: 1.5),
    CartItem(name: "Pineapple", price: 2.0),
  ];

  List<CartItem> cart = [];

  @override
  void initState() {
    super.initState();
    loadCart(); // Load cart from SharedPreferences on app start
  }

  // Load cart from SharedPreferences
  void loadCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartJson = prefs.getString('cart');
    if (cartJson != null) {
      List decoded = jsonDecode(cartJson);
      setState(() {
        cart = decoded.map((item) => CartItem.fromJson(item)).toList();
      });
    }
  }

  // Save cart to SharedPreferences
  void saveCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cartJson = jsonEncode(cart.map((item) => item.toJson()).toList());
    await prefs.setString('cart', cartJson);
  }

  void addToCart(CartItem product) {
    setState(() {
      int index = cart.indexWhere((item) => item.name == product.name);
      if (index >= 0) {
        cart[index].quantity += 1;
      } else {
        cart.add(CartItem(name: product.name, price: product.price));
      }
    });
    saveCart();
  }

  void removeFromCart(int index) {
    setState(() {
      if (cart[index].quantity > 1) {
        cart[index].quantity -= 1;
      } else {
        cart.removeAt(index);
      }
    });
    saveCart();
  }

  double get subtotal => cart.fold(0, (sum, item) => sum + item.price * item.quantity);
  double get tax => subtotal * 0.05;
  double get total => subtotal + tax;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Cart',
      theme: ThemeData(primarySwatch: Colors.green),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text('Simple Cart'),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CartScreen(
                      cart: cart,
                      removeFromCart: removeFromCart,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      '${cart.length} | \$${total.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              CartItem product = products[index];
              return Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.green.shade100,
                        child: Icon(Icons.shopping_bag, color: Colors.green, size: 30),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "\$${product.price.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              int index = cart.indexWhere((item) => item.name == product.name);
                              if (index >= 0) removeFromCart(index);
                            },
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                          ),
                          IconButton(
                            onPressed: () => addToCart(product),
                            icon: Icon(Icons.add_circle, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  final List<CartItem> cart;
  final Function(int) removeFromCart;

  CartScreen({required this.cart, required this.removeFromCart});

  double get subtotal => cart.fold(0, (sum, item) => sum + item.price * item.quantity);
  double get tax => subtotal * 0.05;
  double get total => subtotal + tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Cart")),
      body: cart.isEmpty
          ? Center(child: Text("Your cart is empty!"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      CartItem item = cart[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(child: Text(item.quantity.toString())),
                          title: Text(item.name),
                          subtitle: Text("\$${item.price.toStringAsFixed(2)} each"),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeFromCart(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 4, color: Colors.grey.shade300)],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Subtotal", style: TextStyle(fontSize: 16)),
                          Text("\$${subtotal.toStringAsFixed(2)}"),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tax (5%)", style: TextStyle(fontSize: 16)),
                          Text("\$${tax.toStringAsFixed(2)}"),
                        ],
                      ),
                      Divider(thickness: 1.2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("\$${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.payment),
                        label: Text("Checkout"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
