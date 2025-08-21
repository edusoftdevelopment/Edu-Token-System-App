class LoginInfoModel {
  int? loginId;
  int? employeeCode;
  String? loginName;
  String? password;
  int? stopNegativeKOT;
  String? employeeName;

  LoginInfoModel({
    this.loginId,
    this.employeeCode,
    this.loginName,
    this.password,
    this.stopNegativeKOT,
    this.employeeName,
  });

  LoginInfoModel.fromJson(Map<String, dynamic> json) {
    loginId = json['LoginId'] as int?;
    employeeCode = json['EmployeeCode'] as int?;
    loginName = json['LoginName'] as String?;
    password = json['Password'] as String?;
    stopNegativeKOT = json['StopNegativeKOT'] as int?;
    employeeName = json['EmployeeName'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['LoginId'] = this.loginId;
    data['EmployeeCode'] = this.employeeCode;
    data['LoginName'] = this.loginName;
    data['Password'] = this.password;
    data['StopNegativeKOT'] = this.stopNegativeKOT;
    data['EmployeeName'] = this.employeeName;
    return data;
  }
}
