class CompanyNameModel {
  String? companyName;

  CompanyNameModel({this.companyName});

  CompanyNameModel.fromJson(Map<String, dynamic> json) {
    companyName = json['CompanyName'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CompanyName'] = this.companyName;
    return data;
  }
}
