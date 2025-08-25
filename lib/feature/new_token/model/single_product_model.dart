class SingleProductModel {
  int? tokenID;
  int? tokanNo;
  String? tokenDate;
  int? productID;
  double? quantity;
  double? rate;
  int? userEmployeeID;
  Null? partyID;
  int? posted;
  String? vehicleNo;
  String? productName;

  SingleProductModel({
    this.tokenID,
    this.tokanNo,
    this.tokenDate,
    this.productID,
    this.quantity,
    this.rate,
    this.userEmployeeID,
    this.partyID,
    this.posted,
    this.vehicleNo,
    this.productName,
  });

  SingleProductModel.fromJson(Map<String, dynamic> json) {
    tokenID = json['TokenID'] as int?;
    tokanNo = json['TokanNo'] as int?;
    tokenDate = json['TokenDate'] as String?;
    productID = json['ProductID'] as int?;
    quantity = json['Quantity'] as double?;
    rate = json['Rate'] as double?;
    userEmployeeID = json['UserEmployeeID'] as int?;
    partyID = json['PartyID'] as Null?;
    posted = json['Posted'] as int?;
    vehicleNo = json['VehicleNo'] as String?;
    productName = json['ProductName'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TokenID'] = this.tokenID;
    data['TokanNo'] = this.tokanNo;
    data['TokenDate'] = this.tokenDate;
    data['ProductID'] = this.productID;
    data['Quantity'] = this.quantity;
    data['Rate'] = this.rate;
    data['UserEmployeeID'] = this.userEmployeeID;
    data['PartyID'] = this.partyID;
    data['Posted'] = this.posted;
    data['VehicleNo'] = this.vehicleNo;
    data['ProductName'] = this.productName;
    return data;
  }
}

// class SingleProductModel {
//   int? tokenID;
//   int? tokanNo;
//   String? tokenDate;
//   int? productID;
//   double? quantity;
//   double? rate;
//   int? userEmployeeID;
//   Null? partyID;
//   int? posted;
//   String? productName;

//   SingleProductModel({
//     this.tokenID,
//     this.tokanNo,
//     this.tokenDate,
//     this.productID,
//     this.quantity,
//     this.rate,
//     this.userEmployeeID,
//     this.partyID,
//     this.posted,
//     this.productName,
//   });

//   SingleProductModel.fromJson(Map<String, dynamic> json) {
//     tokenID = json['TokenID'] as int?;
//     tokanNo = json['TokanNo'] as int?;
//     tokenDate = json['TokenDate'] as String?;
//     productID = json['ProductID'] as int?;
//     quantity = json['Quantity'] as double?;
//     rate = json['Rate'] as double?;
//     userEmployeeID = json['UserEmployeeID'] as int?;
//     partyID = json['PartyID'] as Null?;
//     posted = json['Posted'] as int?;
//     productName = json['ProductName'] as String?;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['TokenID'] = this.tokenID;
//     data['TokanNo'] = this.tokanNo;
//     data['TokenDate'] = this.tokenDate;
//     data['ProductID'] = this.productID;
//     data['Quantity'] = this.quantity;
//     data['Rate'] = this.rate;
//     data['UserEmployeeID'] = this.userEmployeeID;
//     data['PartyID'] = this.partyID;
//     data['Posted'] = this.posted;
//     data['ProductName'] = this.productName;
//     return data;
//   }
// }
