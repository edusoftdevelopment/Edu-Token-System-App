class EduTokenSystemHistoryModel {
  const EduTokenSystemHistoryModel({
    this.tokenId,
    this.tokenNo,
    this.tokenDate,
    this.productId,
    this.quantity,
    this.rate,
    this.userEmployeeId,
    this.partyId,
    this.posted,
    this.vehicleNo,
    this.productName,
  });

  factory EduTokenSystemHistoryModel.fromJson(Map<String, dynamic> json) {
    return EduTokenSystemHistoryModel(
      tokenId: json['TokenID'] as int?,
      tokenNo: json['TokanNo'] as int?,
      tokenDate: json['TokenDate'] as String?,
      productId: json['ProductID'] as int?,
      quantity: (json['Quantity'] as num?)?.toDouble(),
      rate: (json['Rate'] as num?)?.toDouble(),
      userEmployeeId: json['UserEmployeeID'] as int?,
      partyId: json['PartyID'] as int?,
      posted: json['Posted'] as int?,
      vehicleNo: json['VehicleNo'] as String?,
      productName: json['ProductName'] as String?,
    );
  }

  final int? tokenId;
  final int? tokenNo;
  final String? tokenDate;
  final int? productId;
  final double? quantity; // 👈 int ki jagah double
  final double? rate; // 👈 int ki jagah double
  final int? userEmployeeId;
  final int? partyId;
  final int? posted;
  final String? vehicleNo;
  final String? productName;

  Map<String, dynamic> toJson() {
    return {
      'TokenID': tokenId,
      'TokanNo': tokenNo,
      'TokenDate': tokenDate,
      'ProductID': productId,
      'Quantity': quantity,
      'Rate': rate,
      'UserEmployeeID': userEmployeeId,
      'PartyID': partyId,
      'Posted': posted,
      'VehicleNo': vehicleNo,
      'ProductName': productName,
    };
  }
}
