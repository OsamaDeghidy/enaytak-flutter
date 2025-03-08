import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class RegistrationProvider with ChangeNotifier {
  // Dropdown selections
  String? selectedLanguage;
  String? selectedCountry;
  String? selectedCity;
  String? selectedDegree;
  String? selectedSpecialization;
  String? selectedClassification;

  // File paths
  String? idCardPath;
  String? photoPath;

  // Submission state
  bool isSubmitting = false;

  // Method to handle file picking
  Future<void> pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      if (type == 'ID Card') {
        idCardPath = result.files.single.name;
      } else if (type == 'Photo') {
        photoPath = result.files.single.name;
      }
      notifyListeners();
    }
  }

  // Method to handle submission
  Future<void> submitRegistration() async {
    isSubmitting = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    isSubmitting = false;
    notifyListeners();
  }

  // Method to update dropdown values
  void updateDropdown(String field, String? value) {
    switch (field) {
      case 'Language':
        selectedLanguage = value;
        break;
      case 'Country':
        selectedCountry = value;
        break;
      case 'City':
        selectedCity = value;
        break;
      case 'Degree':
        selectedDegree = value;
        break;
      case 'Specialization':
        selectedSpecialization = value;
        break;
      case 'Classification':
        selectedClassification = value;
        break;
    }
    notifyListeners();
  }
}
