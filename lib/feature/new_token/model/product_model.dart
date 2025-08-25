class ProductModel {
  int? productID;
  String? productName;
  double? unitPrice;

  ProductModel({this.productID, this.productName, this.unitPrice});

  ProductModel.fromJson(Map<String, dynamic> json) {
    productID = json['ProductID'] as int?;
    productName = json['ProductName'] as String?;
    unitPrice = json['UnitPrice'] as double?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ProductID'] = this.productID;
    data['ProductName'] = this.productName;
    data['UnitPrice'] = this.unitPrice;
    return data;
  }
}
