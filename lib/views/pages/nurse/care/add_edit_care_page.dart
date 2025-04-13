import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/data/class/care_item_class.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/data/providers/care_provider.dart';
import 'package:intl/intl.dart';
import 'package:infy/data/class/patient_class.dart';
import 'package:provider/provider.dart';
import 'package:infy/data/providers/care_item_provider.dart';
import 'package:infy/data/strings.dart';
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

  @override
  void initState() {
    super.initState();

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
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      setState(() {
        _isUploading = true; // Démarre l'animation de chargement
      });

      try {
        for (var image in images) {
          final File originalFile = File(image.path);

          // Compresser l'image originale
          final String compressedPath = '${originalFile.path}_compressed.jpg';
          final File? compressedFile =
              await FlutterImageCompress.compressAndGetFile(
                originalFile.path,
                compressedPath,
                quality: 80,
              );

          if (compressedFile == null) {
            throw Exception(
              "Erreur lors de la compression de l'image originale.",
            );
          }

          // Générer une miniature
          final String thumbnailPath = '${originalFile.path}_thumbnail.jpg';
          final File? thumbnailFile =
              await FlutterImageCompress.compressAndGetFile(
                originalFile.path,
                thumbnailPath,
                quality: 20,
                minWidth: 150,
                minHeight: 150,
              );

          if (thumbnailFile == null) {
            throw Exception("Erreur lors de la génération de la miniature.");
          }

          // Références Firebase Storage
          final storageRef = FirebaseStorage.instance.ref();
          final imagesRef = storageRef.child('images/${image.name}');
          final thumbnailsRef = storageRef.child('thumbnails/${image.name}');

          // Upload de l'image compressée
          await imagesRef.putFile(compressedFile);

          // Upload de la miniature
          await thumbnailsRef.putFile(thumbnailFile);

          // Obtenir les URLs de téléchargement
          final String imageUrl = await imagesRef.getDownloadURL();
          final String thumbnailUrl = await thumbnailsRef.getDownloadURL();

          // Ajouter les URLs à la liste
          setState(() {
            _uploadedImageUrls[thumbnailUrl] = imageUrl;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Images et miniatures uploadées avec succès'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'upload : $e')),
        );
        print(e);
      } finally {
        setState(() {
          _isUploading = false; // Arrête l'animation de chargement
        });
      }
    }
  }

  Future<void> _submitCare() async {
    if (!_formKey.currentState!.validate()) return;

    final String? caretakerId = FirebaseAuth.instance.currentUser?.uid;
    if (caretakerId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.userNotLoggedIn)));
      return;
    }

    // Vérifiez que _uploadedImageUrls contient bien les URLs
    debugPrint('Uploaded Image URLs: $_uploadedImageUrls');

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

      // Recharger les données après la mise à jour
      await careProvider.fetchCareByDate(
        _selectedTimestamp ?? DateTime.now(),
        reload: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.care != null
                ? AppStrings.careUpdatedSuccessfully
                : AppStrings.careAddedSuccessfully,
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${AppStrings.error}: $e')));
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
                                height: 100,
                                width: 100,
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

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  careType,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 4.0,
                                  runSpacing: 4.0,
                                  children:
                                      items.map((careItem) {
                                        final isSelected = _selectedCareItems
                                            .contains(careItem.documentId);
                                        return SizedBox(
                                          width: 100,
                                          height: 40,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                if (isSelected) {
                                                  _selectedCareItems.remove(
                                                    careItem.documentId,
                                                  );
                                                } else {
                                                  _selectedCareItems.add(
                                                    careItem.documentId,
                                                  );
                                                }
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  isSelected
                                                      ? Colors.teal[100]
                                                      : Colors.white10,
                                              padding: EdgeInsets.zero,
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(careItem.name),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                                const SizedBox(height: 16),
                              ],
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
                    onPressed: _submitCare,
                    child: Text(
                      widget.care != null ? AppStrings.update : AppStrings.add,
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
