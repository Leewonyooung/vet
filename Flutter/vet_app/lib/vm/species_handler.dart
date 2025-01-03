import 'package:vet_app/vm/login_handler.dart';
import 'package:get/get.dart';
import 'dart:convert';

class SpeciesHandler extends LoginHandler {
  final selectedSpeciesType = Rx<String?>(null);
  final selectedSpeciesCategory = Rx<String?>(null);
  final speciesTypes = <String>[].obs;
  final speciesCategories = <String>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await loadSpeciesTypes();
    await loadSpeciesCategories('강아지');
  }

  loadSpeciesTypes() async {
    try {
      var response = await makeAuthenticatedRequest('$server/species/types');
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        speciesTypes.value = List<String>.from(data);
      } else {
        throw Exception("Failed to load species types");
      }
    } catch (e) {
      return false;
    }
  }

  loadSpeciesCategories(String speciesType) async {
    try {
      var encodedType = Uri.encodeComponent(speciesType);
      var response = await makeAuthenticatedRequest('$server/species/pet_categories?type=$encodedType');
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        if (data["results"] is List) {
          speciesCategories.value = List<String>.from(data["results"]);
          return true;
        } else {
          throw Exception("Invalid API response format");
        }
      } else {
        throw Exception("Failed to load species categories: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading species categories: $e");
      return false;
    }
  }



  setSpeciesType(String? type) {
    selectedSpeciesType.value = type;
    if (type != null) {
      loadSpeciesCategories(type);
    }
  }

  setSpeciesCategory(String? category) {
    selectedSpeciesCategory.value = category;
  }
}
