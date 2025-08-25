class LoginInfoModel {
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
  int? loginId;
  int? employeeCode;
  String? loginName;
  String? password;
  int? stopNegativeKOT;
  String? employeeName;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['LoginId'] = loginId;
    data['EmployeeCode'] = employeeCode;
    data['LoginName'] = loginName;
    data['Password'] = password;
    data['StopNegativeKOT'] = stopNegativeKOT;
    data['EmployeeName'] = employeeName;
    return data;
  }
}
