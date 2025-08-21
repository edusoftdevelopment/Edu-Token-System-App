class DbListsModel {
  String? defaultDB;
  String? alias;

  DbListsModel({this.defaultDB, this.alias});

  DbListsModel.fromJson(Map<String, dynamic> json) {
    defaultDB = json['DefaultDB'] as String?;
    alias = json['Alias'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DefaultDB'] = this.defaultDB;
    data['Alias'] = this.alias;
    return data;
  }
}