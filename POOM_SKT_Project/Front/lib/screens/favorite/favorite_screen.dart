import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class Product {
  final String id;
  final String image;
  final String name;
  final String detailUrl;

  Product({required this.id, required this.image, required this.name, required this.detailUrl});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      image: json['image'],
      name: json['name'],
      detailUrl: json['detailUrl'],
    );
  }
}

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);
  
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Product> productList = [];

  @override
  void initState() {
    super.initState();
    fetchWishlistProducts();
  }

  // app2.js 서버로부터 제품 목록을 가져오는 메서드
  Future<void> fetchWishlistProducts() async {
    // app2.js 서버의 주소로 변경해야 함. 예를 들어, app2.js가 192.168.1.3:3001에서 실행된다면:
    final response = await http.get(Uri.parse('http:/URL:3001/wishlist'));

    if (response.statusCode == 200) {
      List<dynamic> productJsonList = json.decode(response.body);
      setState(() {
        productList = productJsonList.map((productJson) => Product.fromJson(productJson)).toList();
      });
    } else {
      throw Exception('Failed to load wishlist products');
    }
  }

  // 특정 제품을 위시리스트에서 삭제하는 메서드
  void _deleteProduct(String id) async {
  final response = await http.delete(Uri.parse('http://URL:3001/wishlist/$id'));

  // 서버 응답 로그 출력
  print('Server Response Status: ${response.statusCode}');
  print('Server Response Body: ${response.body}');

  if (response.statusCode == 200) {
    print("Product deletion successful");
    setState(() {
      productList.removeWhere((product) => product.id == id);
    });
    // 삭제 후 제품 목록 갱신
    fetchWishlistProducts();
  } else {
    print("Failed to delete product");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete product')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wishlist"),
      ),
      body: ListView.builder(
        itemCount: productList.length,
        itemBuilder: (context, index) {
          final product = productList[index];
          return ListTile(
            leading: Image.network(product.image),
            title: Text(product.name),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteProduct(product.id),
            ),
            onTap: () => launch(product.detailUrl), // 제품 상세 URL을 기본 웹 브라우저에서 열기
          );
        },
      ),
    );
  }
}
