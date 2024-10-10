import 'package:vet_app/model/pet.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vet_app/vm/species_handler.dart';

class PetHandler extends SpeciesHandler {
  var pets = <Pet>[].obs;

  // 유저 ID를 기반으로 반려동물 정보 가져오기
  Future<void> fetchPets(String userId) async {
    var url = Uri.parse('http://127.0.0.1:8000/pet/pets?user_id=$userId');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        pets.value = (data as List).map((petJson) {
          return Pet(
            id: petJson['id'],
            userId: petJson['user_id'],
            speciesType: petJson['species_type'],
            speciesCategory: petJson['species_category'],
            name: petJson['name'],
            birthday: petJson['birthday'],
            features: petJson['features'],
            gender: petJson['gender'],
            image: petJson['image'],
          );
        }).toList();
      } else {
        // 오류 발생 시 핸들링
        throw Exception("Failed to load pets");
      }
    } catch (e) {
      pets.clear(); // 오류 발생 시 pets 리스트 초기화
    }
  }

  // 반려동물이 등록되어 있는지 확인
  bool hasPets() {
    return pets.isNotEmpty;
  }

  // 반려동물 등록
  Future<bool> addPet(Pet pet) async {
    var url = Uri.parse('http://127.0.0.1:8000/pet/pets');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': pet.userId,
        'species_type': pet.speciesType,
        'species_category': pet.speciesCategory,
        'name': pet.name,
        'birthday': pet.birthday,
        'features': pet.features,
        'gender': pet.gender,
        'image': pet.image,
      }),
    );

    if (response.statusCode == 200) {
      // 반려동물이 성공적으로 등록된 경우 true 반환
      return true;
    } else {
      // 등록 실패 시 false 반환
      return false;
    }
  }
}
