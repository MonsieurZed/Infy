class AppConstants {
  // Date and Locale
  static const String fullTimeFormat = 'EEEE dd MMMM yyyy HH:mm';
  static const String classicTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String hourTimeFormat = 'HH:mm';
  static const String dateFormat = 'dd/MM/yyyy';
  static const String locale = 'fr_FR';
}

class PrefsString {
  static const String themeModeKey = 'themeModeKey';
  static const String isLoggedIn = 'isLoggedIn';
  static const String savedEmail = 'savedEmail';
  static const String savedPassword = 'savedPassword';
  static const String rememberMe = 'rememberMe';
}

class FirebaseString {
  static const String documentId = 'documentId';
  static const String timestamp = 'timestamp';

  // Collections
  static const String collectionCares = 'cares';
  static const String collectionCareItems = 'careItems';
  static const String collectionUsers = 'users';
  static const String collectionPatients = 'patients';

  // Patients
  static const String caregiverId = 'caregiverId';
  static const String patientId = 'patientId';

  static const String patientFirstname = 'firstname';
  static const String patientLastname = 'lastname';
  static const String patientDob = 'dob';
  static const String patientaddress = 'address';
  static const String patientOtherInfo = 'otherInfo';
  static const String patientCaregivers = 'caregivers';

  // CareItem
  static const String careItemId = 'code';
  static const String careItemName = 'name';
  static const String careItemType = 'careType';

  // Cares
  static const String careCoordinate = 'coordinates';
  static const String carePerformed = 'carePerformed';
  static const String careInfo = 'careInfo';
  static const String careImages = 'imgs';

  // Users
}

class LottiesString {
  static const String loading = 'assets/lotties/loading.json';
  static const String home = 'assets/lotties/home.json';
}

class ImageString {
  static const String logo = 'assets/images/icon.png';
  static const String logoFull = 'assets/images/icon-full.png';
  static const String bg = 'assets/images/bg.png';
}
