import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infy/class/care_class.dart';
import 'package:infy/class/care_item_class.dart';
import 'package:infy/contants/constants.dart';
import 'package:infy/providers/care_provider.dart';
import 'package:infy/contants/strings.dart';
import 'package:infy/utils/app_logger.dart';
import 'package:infy/ui/mobile/pages/caregivers/care/widget/care_careitem_widget.dart';
import 'package:intl/intl.dart';
import 'package:infy/class/patient_class.dart';
import 'package:provider/provider.dart';
import 'package:infy/providers/care_item_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AddEditCarePage extends StatefulWidget {
  const AddEditCarePage({super.key, required this.patient, this.care});

  final Patient patient;
  final Care? care;

  @override
  State<AddEditCarePage> createState() => _AddEditCarePageState();
}

class _AddEditCarePageState extends State<AddEditCarePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _infoController = TextEditingController();

  DateTime? _selectedTimestamp;
  List<String> _selectedCareItems = [];
  Map<String, String> _uploadedImageUrls = {};
  bool _isUploading = false;

  // Constants for retry mechanism
  static const int _maxRetries = 3;
  static const Duration _initialBackoff = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();

    // S'assurer que les CareItems sont rechargés depuis Firebase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CareItemProvider>(context, listen: false).fetchCareItems();
    });

    if (widget.care != null) {
      final care = widget.care!;
      _selectedTimestamp = care.timestamp.toDate();
      _selectedCareItems = List.from(care.performed);
      _infoController.text = care.info ?? '';
      _uploadedImageUrls = Map.from(care.images);
    } else {
      _selectedTimestamp = DateTime.now();
    }
  }

  Future<void> _pickAndUploadImages() async {
    final ImagePicker picker = ImagePicker();

    try {
      final List<XFile> images = await picker.pickMultiImage(imageQuality: 25);

      if (images.isEmpty) {
        return; // Ne rien faire si aucune image n'est sélectionnée
      }

      setState(() {
        _isUploading = true; // Démarre l'animation de chargement
      });

      for (var image in images) {
        try {
          final File originalFile = File(image.path);
          final String name =
              "${image.name}_${DateTime.now().millisecondsSinceEpoch}";
          // Compresser l'image originale
          final String compressedPath =
              '${originalFile.path}_${DateTime.now().millisecondsSinceEpoch}compressed.webp';
          final compressedFile = await FlutterImageCompress.compressAndGetFile(
            originalFile.path,
            compressedPath,
            minWidth: 1200,
            minHeight: 1200,
            quality: 50,
            format: CompressFormat.webp,
          );

          if (compressedFile == null) {
            throw Exception("Error while compressing the original image.");
          }

          // Générer une miniature
          final String thumbnailPath = '${originalFile.path}_thumbnail.webp';
          final thumbnailFile = await FlutterImageCompress.compressAndGetFile(
            originalFile.path,
            thumbnailPath,
            quality: 5,
            minWidth: 150,
            minHeight: 150,
            format: CompressFormat.webp,
          );

          if (thumbnailFile == null) {
            throw Exception("Error while generating the thumbnail.");
          }

          // Upload files with retry mechanism
          final imageUrl = await _uploadFileWithRetry(
            compressedFile.path,
            'images/$name',
            'image/webp',
          );

          final thumbnailUrl = await _uploadFileWithRetry(
            thumbnailFile.path,
            'thumbnails/${image.name}',
            'image/webp',
          );

          // Ajouter les URLs à la liste
          setState(() {
            _uploadedImageUrls[thumbnailUrl] = imageUrl;
          });
        } catch (e) {
          // Gérer les erreurs par image individuellement
          var message = 'Erreur lors de l\'upload de l\'image: $e';
          AppLogger.snackbar(context, message);
          AppLogger.e(message);
          // Continuer avec les autres images même si celle-ci échoue
        }
      }

      if (_uploadedImageUrls.isNotEmpty) {
        AppLogger.snackbar(context, AppStrings.imagesUploadedSuccessfully);
      }
    } catch (e) {
      var message = 'Erreur lors de l\'upload des images : $e';
      AppLogger.snackbar(context, message);
      AppLogger.e(message);
    } finally {
      // Assurer que l'indicateur de chargement est désactivé dans tous les cas
      if (mounted) {
        // Vérifier si le widget est toujours monté
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  /// Upload a file to Firebase Storage with exponential backoff retry mechanism
  Future<String> _uploadFileWithRetry(
    String filePath,
    String storagePath,
    String contentType, {
    int attempt = 1,
  }) async {
    try {
      // Create Firebase Storage reference
      final storageRef = FirebaseStorage.instance.ref();
      final fileRef = storageRef.child(storagePath);

      // Create metadata
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {'picked-file-path': filePath},
      );

      // Upload file
      await fileRef.putFile(File(filePath), metadata);

      // Return download URL
      return await fileRef.getDownloadURL();
    } catch (e) {
      // Check if this is an App Check token error
      if (e.toString().contains('Too many attempts') && attempt < _maxRetries) {
        // Calculate exponential backoff time
        final backoffTime = _initialBackoff * (attempt * 2);

        AppLogger.e(
          'App Check token error. Retrying upload in ${backoffTime.inSeconds} seconds (attempt $attempt/$_maxRetries)',
        );

        // Wait with exponential backoff
        await Future.delayed(backoffTime);

        // Retry with increased attempt count
        return _uploadFileWithRetry(
          filePath,
          storagePath,
          contentType,
          attempt: attempt + 1,
        );
      } else {
        // Rethrow other errors or if max retries reached
        rethrow;
      }
    }
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedTimestamp ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedTimestamp ?? DateTime.now(),
        ),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedTimestamp = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitCare() async {
    if (!_formKey.currentState!.validate()) return;

    final String? caretakerId = FirebaseAuth.instance.currentUser?.uid;
    if (caretakerId == null) {
      AppLogger.snackbar(context, AppStrings.userNotLoggedIn);
      return;
    }

    final care = Care(
      documentId:
          widget.care?.documentId ??
          widget.patient.documentId +
              DateFormat('yyyyMMddHHmmss').format(_selectedTimestamp!),
      caregiverId: caretakerId,
      patientId: widget.patient.documentId,
      timestamp: Timestamp.fromDate(_selectedTimestamp ?? DateTime.now()),
      coordinates: {},
      performed: _selectedCareItems,
      info: _infoController.text.trim(),
      images:
          _uploadedImageUrls, // Assurez-vous que cette liste est bien passée
    );

    try {
      final careProvider = Provider.of<CareProvider>(context, listen: false);

      // Ajout ou mise à jour du soin
      await careProvider.submitCare(care: care);

      AppLogger.snackbar(
        context,
        widget.care != null
            ? AppStrings.careUpdatedSuccessfully
            : AppStrings.careAddedSuccessfully,
      );

      Navigator.pop(context, true);
    } catch (e) {
      AppLogger.snackbar(context, '${AppStrings.error}: $e');
      AppLogger.e('${AppStrings.error}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.care != null ? AppStrings.editCare : AppStrings.addCare,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.patient}: ${widget.patient.firstName} ${widget.patient.lastName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickDateTime,
                  child: Text(
                    _selectedTimestamp == null
                        ? AppStrings.selectDateTime
                        : DateFormat(
                          AppConstants.classicTimeFormat,
                        ).format(_selectedTimestamp!),
                  ),
                ),
                const SizedBox(height: 16),
                if (_uploadedImageUrls.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children:
                        _uploadedImageUrls.entries.map((entry) {
                          return Stack(
                            children: [
                              Image.network(
                                entry.key, // Thumbnail URL
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _uploadedImageUrls.remove(entry.key);
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ElevatedButton(
                  onPressed: _pickAndUploadImages,
                  child: const Text('Ajouter des photos'),
                ),
                const SizedBox(height: 16),
                if (_isUploading)
                  const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 16),
                Consumer<CareItemProvider>(
                  builder: (context, careItemProvider, child) {
                    final careItems = careItemProvider.careItems;
                    final groupedCareItems = <String, List<CareItem>>{};

                    for (var careItem in careItems) {
                      groupedCareItems
                          .putIfAbsent(careItem.careType, () => [])
                          .add(careItem);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          groupedCareItems.entries.map((entry) {
                            final careType = entry.key;
                            final items = entry.value;

                            return CareItemsWidget(
                              careType: careType,
                              items: items,
                              selectedCareItems: _selectedCareItems,
                              onItemSelected: (documentId) {
                                setState(() {
                                  if (_selectedCareItems.contains(documentId)) {
                                    _selectedCareItems.remove(documentId);
                                  } else {
                                    _selectedCareItems.add(documentId);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _infoController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.annotationLabel,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _submitCare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isUploading ? Colors.grey : Colors.teal,
                    ),
                    child: Text(
                      widget.care != null ? AppStrings.update : AppStrings.add,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
