class ProductModel {
  final int id;
  final String name;
  final double price;
  final double? promoPrice;
  final int stock;
  final String? barcode;
  final String? unit;
  final String initials;
  final String? imageUrl;
  final String? categoryName;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.promoPrice,
    required this.stock,
    this.barcode,
    this.unit,
    required this.initials,
    this.imageUrl,
    this.categoryName,
  });

  double get effectivePrice => promoPrice ?? price;

  bool get inStock => stock > 0;

  factory ProductModel.fromJson(Map<String, dynamic> j) => ProductModel(
    id:           j['id'],
    name:         j['name'] ?? '',
    price:        (j['sale_price'] as num).toDouble(),
    promoPrice:   j['promo_price'] != null ? (j['promo_price'] as num).toDouble() : null,
    stock:        j['stock'] ?? 0,
    barcode:      j['barcode'],
    unit:         j['unit'],
    initials:     j['initials'] ?? '??',
    imageUrl:     j['image_url'],
    categoryName: j['category']?['name'],
  );
}
