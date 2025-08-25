class ProductModel {
  ProductModel({this.productID, this.productName, this.unitPrice});

  ProductModel.fromJson(Map<String, dynamic> json) {
    productID = json['ProductID'] as int?;
    productName = json['ProductName'] as String?;
    unitPrice = json['UnitPrice'] as double?;
  }
  int? productID;
  String? productName;
  double? unitPrice;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ProductID'] = productID;
    data['ProductName'] = productName;
    data['UnitPrice'] = unitPrice;
    return data;
  }
}
