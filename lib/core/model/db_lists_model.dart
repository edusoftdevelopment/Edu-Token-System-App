class DbListsModel {
  DbListsModel({this.defaultDB, this.alias});

  DbListsModel.fromJson(Map<String, dynamic> json) {
    defaultDB = json['DefaultDB'] as String?;
    alias = json['Alias'] as String?;
  }
  String? defaultDB;
  String? alias;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['DefaultDB'] = defaultDB;
    data['Alias'] = alias;
    return data;
  }
}
