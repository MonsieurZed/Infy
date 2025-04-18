// General Strings
class AppStrings {
  // App General
  static const String appTitle = 'Infy';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String confirmButton = 'Confirm'; // Fusionné avec confirm
  static const String cancelButton = 'Cancel'; // Fusionné avec cancel
  static const String error = 'Error';
  static const String genericError = 'An error occurred.';
  static const String genericResetError =
      'An error occurred. Please try again.';
  static const String notProvided = 'Not provided';
  static const String add = 'Add';
  static const String update = 'Update';
  static const String submit = 'Submit';
  static const String saveChanges = 'Save Changes';
  static const String saving = 'Saving...';
  static const String search = 'Search';
  static const String noResults = 'No results found.';
  static const String delete = 'Delete';
  static const String deleteButton = 'Delete'; // Fusionné avec delete
  static const String createdAt = 'created at';
  static const String updatedAt = 'updated at';
  static const String backToHome = 'Back to Home';
  static const String years = 'years';
  static const String closeButton = 'Fermer';

  // Navigation & UI
  static const String navbarCare = 'Care';
  static const String navbarHome = 'Home';
  static const String navbarPatients = 'Patients';
  static const String dashboard = 'Dashboard';
  static const String welcome = 'Welcome';
  static const String dashboardDescription =
      'Manage your patients and their care.';

  // Welcome & Splash Screen
  static const String welcomeMessage = 'Welcome to Infy';
  static const String welcomeBack =
      'Welcome back! Please log in to your account.';
  static const String loadingComplete = 'Loading complete.';
  static const String caregiverButton = 'Caregiver';
  static const String patientButton = 'Patient';
  static const String errorLoadingProviders = 'Error loading providers';

  // Authentication - General
  static const String loginButton = 'Login';
  static const String emailLabel = 'Email';
  static const String emailHint = 'Enter your email address';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String rememberMe = 'Remember Me';
  static const String userNotLoggedIn = 'User not logged in.';
  static const String userNotFound = 'User not found.';
  static const String noUserFound =
      'No user found with this email.'; // Fusionné avec userNotFound
  static const String incorrectPassword = 'Incorrect password.';
  static const String invalidEmail = 'Invalid email.';
  static const String invalidEmailError =
      'Invalid email address.'; // Fusionné avec invalidEmail
  static const String logout = 'logout';
  static const String logoutButton = 'Logout'; // Fusionné avec logout
  static const String errorLogout = 'Error during logout';
  static const String logoutError =
      'Error during logout.'; // Fusionné avec errorLogout
  static const String errorAutoLoginFailed = 'Auto-login failed';

  // Caregiver Authentication
  static const String forgotPassword = 'Forgot Password? Reset Here';
  static const String signupTitle = 'Sign Up';
  static const String signupButton = 'Sign Up';
  static const String createAccount = 'Create an account';
  static const String accountCreated = 'Account Created';
  static const String emailAlreadyInUse = 'Email already in use';
  static const String weakPassword = 'Weak password';
  static const String emailRequired = 'Email is required';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String confirmPasswordHint = 'Confirm your password';
  static const String confirmPasswordRequired = 'Confirm Password is required';
  static const String alreadyHaveAccount = 'Already have an account? Login';
  static const String dontHaveAccount = 'Don\'t have an account?';
  static const String enterAllFields = 'Email and password are required.';
  static const String passwordsDoNotMatch = 'Passwords does not match.';
  static const String backToLogin = 'Back to login';

  // Password Reset
  static const String resetPasswordTitle = 'Reset Password';
  static const String sendResetEmail = 'Send Reset Email';
  static const String enterEmailPrompt = 'Please enter your email address.';
  static const String resetEmailSent = 'Password reset email sent.';
  static const String resetPasswordInstructions =
      'Enter your email address to receive a password reset link.';

  // Patient Authentication
  static const String invalidPatientId = 'Invalid patient code.';
  static const String enterPatientCode = 'Enter Patient Code';
  static const String pleaseEnterPatientCode = 'Please enter the patient code.';
  static const String patientCodeSizeIncorrect =
      'The patient code must be 9 characters long.';
  static const String patientId = 'Patient ID';
  static const String enterValidPatientId = 'Please enter a valid patient ID.';

  // User Profile
  static const String profile = 'Profile';
  static const String profileUpdated = 'Profile Updated';
  static const String errorUpdatingProfile = 'Error Updating Profile';
  static const String firstNameLabel = 'First Name';
  static const String lastNameLabel = 'Last Name';
  static const String firstNameHint = 'Enter your first name';
  static const String lastNameHint = 'Enter your last name';
  static const String firstNameRequired = 'First Name is required';
  static const String lastNameRequired = 'Last Name is required';
  static const String enterFirstName = 'Please enter the first name.';
  static const String enterLastName = 'Please enter the last name.';

  // Patient Management
  static const String patient = 'Patient';
  static const String patients = 'Patients';
  static const String managePatients = 'Manage your patients';
  static const String patientDetailsTitle = 'Patient Details';
  static const String patientDetails =
      'Patient Details'; // Fusionné avec patientDetailsTitle
  static const String editPatientTooltip = 'Edit patient';
  static const String removePatientTooltip = 'Remove patient';
  static const String addPatient = 'Add Patient';
  static const String editPatient = 'Edit Patient';
  static const String addNewPatient = 'Add New Patient';
  static const String createPatient = 'Create Patient';
  static const String patientNotFound = 'No patient found with this ID.';
  static const String noPatients = 'No patients found.';
  static const String addedAsCaregiver = 'You have been added as a caregiver.';
  static const String alreadyCaregiver =
      'You are already a caregiver for this patient.';
  static const String patientSavedSuccessfully = 'Patient successfully saved!';
  static const String patientAddedSuccessfully =
      'Patient added successfully!'; // Fusionné avec patientSavedSuccessfully
  static const String patientUpdatedSuccessfully =
      'Patient updated successfully!';
  static const String importPatient = 'Import patient';
  static const String selectPatient = 'Select a Patient';
  static const String selectPatientDescription =
      'Select a patient to view details.';

  // Patient Information
  static const String personalInformation = 'Personal Information';
  static const String enterStreet = 'Please enter the street.';
  static const String enterPostalCode = 'Please enter the postal code.';
  static const String postalCodeLength = 'Postal code must be 5 digits.';
  static const String addressNotAvailable = 'Address not available';
  static const String enterCity = 'Please enter the city.';
  static const String selectDateOfBirth = 'Select Date of Birth';
  static const String saveNewPatient = 'Save New Patient';
  static const String postalCode = 'Postal Code';
  static const String address = 'Address';
  static const String street = 'Street';
  static const String city = 'City';
  static const String dateOfBirth = 'Date of Birth';
  static const String selectDate = 'Select a date';
  static const String age = 'Age';
  static const String patientLabel = 'Patient'; // Fusionné avec patient
  static const String additionalInformation = 'Additional Information';
  static const String additionalInfoDescription =
      'Provide any additional information about the patient.';
  static const String notes = 'Notes';

  // Patient Relationship Management
  static const String confirmationTitle = 'Confirmation';
  static const String confirmDeletionTitle =
      'Confirm Deletion'; // Lié à confirmationTitle
  static const String confirmDeletionMessage =
      'Are you sure you want to delete this care?';
  static const String removePatientPrompt =
      'Are you sure you want to remove yourself from this patient?';
  static const String removedFromPatient =
      'You have been removed from this patient.';
  static const String notCaregiverForPatient =
      'You are not a caregiver for this patient.';
  static const String caregivers = 'Caregivers';
  static const String caregiversDescription =
      'List of caregivers associated with this patient.';

  // Care Management
  static const String care = 'Care';
  static const String cares = 'Cares';
  static const String manageCares = 'Manage your care.';
  static const String manageCareItems = 'Manage your care items';
  static const String careListTitle = 'Care List:';
  static const String noCareFound = 'No care found.';
  static const String caregiverNotFound = 'Unknown caregiver';
  static const String careDeletedSuccessfully = 'Care deleted successfully.';
  static const String careUpdatedSuccessfully = 'Care updated successfully!';
  static const String careAddedSuccessfully = 'Care added successfully!';
  static const String selectCareItems = 'Select Care Items';
  static const String selectDateTime = 'Select Date and Time';
  static const String selectCarePerformed = 'Select Care Performed';
  static const String editCare = 'Edit Care';
  static const String addCare = 'Add Care';
  static const String dateTimeLabel = 'Date and Time';
  static const String annotationLabel = 'Annotation';
  static const String carePerformedLabel = 'Care Performed';
  static const String careDetailsTitle = 'Care Details';
  static const String planning = 'Planning';
  static const String managePlanning = 'Manage your planning.';
  static const String viewHistory = 'View History';

  // Image Management
  static const String images = 'Images';
  static const String imagesUploadedSuccessfully =
      'Images uploaded successfully';
  static const String imageViewerTitle = 'Image';
  static const String previousImage = 'Image précédente';
  static const String nextImage = 'Image suivante';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String settings = 'Settings'; // Fusionné avec settingsTitle
  static const String manageSettings = 'Manage your settings.';
  static const String darkModeToggle = 'Dark Mode';

  // Error Messages
  static const String errorRetrievingitem = 'Error retrieving item';
  static const String errorFetchingItem = 'Error fetching item';
  static const String errorUpdatingItem = 'Error updating item';
  static const String errorAddingItem = 'Error adding item';
  static const String errorDeletingItem = 'Error deleting item';
  static const String errorSubmittingItem = 'Error submitting item';

  // Debug Values
  static const String debugMethodCalled = 'Method called';
  static const String debugFunctionCalled = 'Function called';
  static const String debugStateChanged = 'State changed';
  static const String debugDataLoaded = 'Data loaded';
  static const String debugApiCalled = 'API called';
  static const String debugUserAction = 'User action detected';
  static const String testUserEmail = 'test@example.com';
  static const String testUserPassword = 'password123';

  // Home Page
  static const String homePagePlaceholder = "I don't know yet";
  static const String searchbarPatient = 'Search for a patient';
}
