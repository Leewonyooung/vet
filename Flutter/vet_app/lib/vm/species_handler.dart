import 'package:vet_app/vm/login_handler.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
    var url = Uri.parse('$server/species/types');
    try {
      var response = await http.get(url);
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
    var url = Uri.parse(
        '$server/species/pet_categories?type=$speciesType');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        speciesCategories.value = List<String>.from(data);
      } else {
        throw Exception("Failed to load species categories");
      }
    } catch (e) {
      return false;
    }
    // selectedSpeciesCategory.value = null;
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
