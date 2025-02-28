import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final int price;

  const Product({
    required this.id,
    required this.name,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: json['price'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [id, name, price];
}
