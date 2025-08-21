class AppConfig {
  // Device
  static String mobileSerialNumber = '';

  // Primary DB (fill with your server details)
  static String dbHost = '192.168.7.3/EDU2K8'; // example IP - change to your server
  static int dbPort = 1433; // MSSQL default port
  static String dbUser = 'sa'; // SQL Server default username
  static String dbPassword = '2MSZXGYTUOM4';
  static String initialDatabase = 'EDU2K8';
  static String currentDatabase = '';

  // Optional second branch/server (if you use branch selection)
  static String dbHost2 = '';
  static int dbPort2 = 1433;
  static String dbUser2 = '';
  static String dbPassword2 = '';
  static String initialDatabase2 = '';

  // AES key/iv used by Android CryptLib if you want to decrypt AppExpiry
  // Put exact key and iv used by your Java CryptLib here (if available)
  static String aesKey = ''; // e.g. '0123456789abcdef0123456789abcdef'
  static String aesIv = ''; // e.g. '0123456789abcdef'

  // runtime values filled after login
  static String loginId = '';
  static String employeeCode = '';
  static String employeeName = '';
  static String cashCounterId = '';
  static String stopNegativeKOT = '';
  static List<String> allowedRights = [];

  // Additional properties from your Java code
  static List<String> myCategories = [];
  static List<String> myProducts = [];
  static List<String> currentProducts = [];
  static double totalPrice = 0;
  static String selectedTable = '';
  static String selectedServingAreaID = '';
  static String selectedSalesmanID = '';
  static String selectedServingUnitID = '';
  static String selectedServingAreaTitle = '';
  static String selectedSalesmanTitle = '';
  static String selectedServingUnitTitle = '';
  static bool previousOrder = false;
  static bool goToPosition = false;
  static int goToPPosition = 0;
  static String selectedCustomerPartyTitle = '';
  static String selectedCustomerPartyID = '';
  static String selectedCustomerPartyTypeTitle = '';
  static String selectedCustomerPartyTypeID = '';
  static String selectedCustomerAddress = '';
  static String selectedCustomerPhone = '';
  static String selectedCustomerName = '';

  // Server configuration
  static String oDbServer = '';
  static String oDbPassword = '';
  static String oDbName = 'eduConnectionDB';
  static String dbServer = '';
  static String dbName = 'eduConnectionDB';

  // Cryptography
  static String key = ''; // Encryption key
  static String iv = ''; // Initialization vector

  // Version info
  static String myVersion = '1.0.0';

  // Filter settings
  static bool filterRealTime = false;
  static bool reportsMultiline = false;
}
