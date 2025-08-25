class AppConfig {
  // Device
  static String mobileSerialNumber = '';

  // Primary DB (fill with your server details)
  static String dbHost = '192.168.7.3'; // example IP - change to your server
  static String dbPort = '4914'; // MSSQL default port
  static String dbUser = 'sa'; // SQL Server default username
  static String dbPassword = '2MSZXGYTUOM4';
  static String initialDatabase = 'eduConnectionDB';
  static String currentDatabase = '';


  // runtime values filled after login
  static String loginId = '';
  static String employeeCode = '';
  static String employeeName = '';
  static String loginName = r'\EDU2K8';


}
