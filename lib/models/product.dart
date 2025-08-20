import 'dart:convert';

class Product {
  final String id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  // Convert Product to Map for SharedPreferences
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'price': price};
  }

  // Convert Map back to Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
    );
  }

  // Encode Product to JSON string
  String toJson() => json.encode(toMap());

  // Decode JSON string to Product
  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));
}
