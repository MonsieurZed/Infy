import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class FirebaseAppCheckService {
  static bool _isInitialized = false;
  static const int _maxRetries = 3;
  static const Duration _initialBackoff = Duration(seconds: 2);
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss');

  /// Initialize Firebase App Check
  ///
  /// This must be called AFTER Firebase.initializeApp()
  static Future<void> initialize() async {
    // Avoid multiple initializations which can cause the exception
    if (_isInitialized) return;

    try {
      await _initializeWithRetry(1);
      _isInitialized = true;
      final message = 'Firebase App Check initialized successfully';
      debugPrint(message);
      await writeToLogFile(message);
    } catch (e) {
      final error = 'Error initializing Firebase App Check: $e';
      debugPrint(error);
      await writeToLogFile(error);
      // We don't want to crash the app if App Check fails to initialize
      // Firebase services will still work, but will use a fallback token
    }
  }

  /// Write log message to file
  static Future<void> writeToLogFile(String message) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDirectory = Directory('${directory.path}/logs');

      // Create logs directory if it doesn't exist
      if (!await logDirectory.exists()) {
        await logDirectory.create(recursive: true);
      }

      final today = DateTime.now();
      final fileName = '${_dateFormat.format(today)}_firebase_app_check.log';
      final file = File('${logDirectory.path}/$fileName');

      // Format log entry with timestamp
      final timestamp = _timeFormat.format(today);
      final logEntry = '[$timestamp] $message\n';

      // Append to log file
      await file.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      // If we can't write to the log file, just print to console
      debugPrint('Failed to write to log file: $e');
    }
  }

  /// Initialize App Check with retry mechanism and exponential backoff
  static Future<void> _initializeWithRetry(int attempt) async {
    try {
      // First, try with simple parameters to ensure plugin is registered
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
      );

      // Wait for platform channel to be established
      await Future.delayed(const Duration(milliseconds: 500));

      // Then configure with the full settings
      await FirebaseAppCheck.instance.activate(
        // For Android, use debug in debug mode and Play Integrity in release
        androidProvider:
            kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
        // For iOS, use debug in debug mode and DeviceCheck in release
        appleProvider:
            kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      );
    } on PlatformException catch (e) {
      final errorMsg =
          'PlatformException initializing Firebase App Check: ${e.message}';
      debugPrint(errorMsg);
      await writeToLogFile(errorMsg);

      // Check if the error is "Too many attempts"
      if (e.message?.contains('Too many attempts') ?? false) {
        if (attempt < _maxRetries) {
          // Calculate exponential backoff time
          final backoffTime = _initialBackoff * (attempt * 2);
          final retryMsg =
              'Too many attempts error. Retrying in ${backoffTime.inSeconds} seconds (attempt $attempt/$_maxRetries)';
          debugPrint(retryMsg);
          await writeToLogFile(retryMsg);

          // Wait with exponential backoff
          await Future.delayed(backoffTime);

          // Retry with increased attempt count
          return _initializeWithRetry(attempt + 1);
        } else {
          final maxRetryMsg =
              'Maximum retry attempts reached. Using fallback token.';
          debugPrint(maxRetryMsg);
          await writeToLogFile(maxRetryMsg);
          // Use debug provider as a last resort
          await FirebaseAppCheck.instance.activate(
            androidProvider: AndroidProvider.debug,
            appleProvider: AppleProvider.debug,
          );
        }
      } else if (e.message?.contains('No implementation found') ?? false) {
        // This might happen on first app run - let's try a simpler approach
        try {
          // Wait a moment and try again with only debug provider
          await Future.delayed(const Duration(seconds: 1));
          await FirebaseAppCheck.instance.activate(
            androidProvider: AndroidProvider.debug,
          );
          final fallbackMsg =
              'Firebase App Check initialized with fallback method';
          debugPrint(fallbackMsg);
          await writeToLogFile(fallbackMsg);
        } catch (innerE) {
          final innerErrorMsg =
              'Failed to initialize App Check with fallback: $innerE';
          debugPrint(innerErrorMsg);
          await writeToLogFile(innerErrorMsg);
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  /// Récupère le chemin vers le fichier de log du jour
  static Future<String?> getLogFilePath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDirectory = Directory('${directory.path}/logs');
      if (!await logDirectory.exists()) {
        return null;
      }

      final today = DateTime.now();
      final fileName = '${_dateFormat.format(today)}_firebase_app_check.log';
      final filePath = '${logDirectory.path}/$fileName';

      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting log file path: $e');
      return null;
    }
  }
}
