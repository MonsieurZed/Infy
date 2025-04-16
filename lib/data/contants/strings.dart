// General Strings
class AppStrings {
  // App General
  static const String appTitle = 'Infy';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String patient = 'Patient';
  static const String error = 'Error';
  static const String genericError = 'An error occurred.';
  static const String notProvided = 'Not provided';
  static const String add = 'Add';
  static const String update = 'Update';
  static const String submit = 'Submit';
  static const String saveChanges = 'Save Changes';
  static const String createdAt = 'created at';
  static const String updatedAt = 'updated at';

  // Welcome & Splash Screen
  static const String welcomeMessage = 'Welcome to Infy';
  static const String loadingComplete = 'Loading complete.';
  static const String caregiverButton = 'Caregiver';
  static const String patientButton = 'Patient';
  static const String errorLoadingProviders = 'Error loading providers';

  // Authentication - General
  static const String loginButton = 'Login';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String rememberMe = 'Remember Me';
  static const String userNotLoggedIn = 'User not logged in.';
  static const String userNotFound = 'User not found.';
  static const String incorrectPassword = 'Incorrect password.';
  static const String invalidEmail = 'Invalid email.';
  static const String logout = 'logout';
  static const String errorLogout = 'Error during logout';
  static const String errorAutoLoginFailed = 'Auto-login failed';

  // Caregiver Authentication
  static const String forgotPassword = 'Forgot Password? Reset Here';
  static const String signupTitle = 'Sign Up';
  static const String signupButton = 'Sign Up';
  static const String accountCreated = 'Account Created';
  static const String emailAlreadyInUse = 'Email already in use';
  static const String weakPassword = 'Weak password';
  static const String emailRequired = 'Email is required';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String confirmPasswordRequired = 'Confirm Password is required';
  static const String alreadyHaveAccount = 'Already have an account? Login';
  static const String dontHaveAccount = 'Don\'t have an account?';
  static const String enterAllFields = 'Email and password are required.';

  // Password Reset
  static const String resetPasswordTitle = 'Reset Password';
  static const String sendResetEmail = 'Send Reset Email';
  static const String enterEmailPrompt = 'Please enter your email address.';
  static const String resetEmailSent = 'Password reset email sent.';
  static const String noUserFound = 'No user found with this email.';
  static const String invalidEmailError = 'Invalid email address.';
  static const String passwordsDoNotMatch = 'Passwords does not match.';
  static const String genericResetError =
      'An error occurred. Please try again.';

  // Patient Authentication
  static const String invalidPatientId = 'Invalid patient code.';
  static const String enterPatientCode = 'Enter Patient Code';
  static const String pleaseEnterPatientCode = 'Please enter the patient code.';
  static const String patientCodeSizeIncorrect =
      'The patient code must be 9 characters long.';
  static const String patientId = 'Patient ID';

  // Navigation
  static const String navbarCare = 'Care';
  static const String navbarHome = 'Home';
  static const String navbarPatients = 'Patients';

  // Home Page
  static const String homePagePlaceholder = "I don't know yet";
  static const String searchbarPatient = 'Search for a patient';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String darkModeToggle = 'Dark Mode';
  static const String logoutButton = 'Logout';

  // User Profile
  static const String profile = 'Profile';
  static const String profileUpdated = 'Profile Updated';
  static const String errorUpdatingProfile = 'Error Updating Profile';
  static const String firstNameLabel = 'First Name';
  static const String lastNameLabel = 'Last Name';
  static const String firstNameRequired = 'First Name is required';
  static const String lastNameRequired = 'Last Name is required';
  static const String enterFirstName = 'Please enter the first name.';
  static const String enterLastName = 'Please enter the last name.';

  // Patient Management
  static const String patientDetailsTitle = 'Patient Details';
  static const String editPatientTooltip = 'Edit patient';
  static const String removePatientTooltip = 'Remove patient';
  static const String addPatient = 'Add Patient';
  static const String editPatient = 'Edit Patient';
  static const String enterValidPatientId = 'Please enter a valid patient ID.';
  static const String patientNotFound = 'No patient found with this ID.';
  static const String addedAsCaregiver = 'You have been added as a caregiver.';
  static const String alreadyCaregiver =
      'You are already a caregiver for this patient.';
  static const String patientSavedSuccessfully = 'Patient successfully saved!';
  static const String importPatient = 'Import patient';
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
  static const String patientLabel = 'Patient';

  // Patient Relationship Management
  static const String confirmationTitle = 'Confirmation';
  static const String confirmButton = 'Confirm';
  static const String cancelButton = 'Cancel';
  static const String removePatientPrompt =
      'Are you sure you want to remove yourself from this patient?';
  static const String removedFromPatient =
      'You have been removed from this patient.';
  static const String notCaregiverForPatient =
      'You are not a caregiver for this patient.';

  // Care Management
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
  static const String care = 'Care';
  static const String images = 'Images';
  static const String imagesUploadedSuccessfully =
      'Images uploaded successfully';

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

  // Confirmation Dialogs
  static const String confirmDeletionTitle = 'Confirm Deletion';
  static const String confirmDeletionMessage =
      'Are you sure you want to delete this care?';
  static const String deleteButton = 'Delete';
}
