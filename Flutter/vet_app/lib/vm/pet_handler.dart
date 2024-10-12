import 'package:vet_app/model/pet.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:vet_app/vm/species_handler.dart';

class PetHandler extends SpeciesHandler {
  var pets = <Pet>[].obs;

  @override
  void onInit() async {
    super.onInit();
    if (box.read('userEmail') == null) {
      box.write('userEmail', '');
    }
    await fetchPets(box.read('userEmail'));
  }

  // 유저 ID를 기반으로 반려동물 정보 가져오기
  fetchPets(String userId) async {
    var url = Uri.parse('http://127.0.0.1:8000/pet/pets?user_id=$userId');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
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

  // 반려동물 등록 (이미지 파일을 포함)
  addPet(Pet pet, File? imageFile) async {
    var url = Uri.parse('http://127.0.0.1:8000/pet/insert');

    var request = http.MultipartRequest('POST', url)
      ..fields['id'] = pet.id
      ..fields['user_id'] = pet.userId
      ..fields['species_type'] = pet.speciesType
      ..fields['species_category'] = pet.speciesCategory
      ..fields['name'] = pet.name
      ..fields['birthday'] = pet.birthday
      ..fields['features'] = pet.features
      ..fields['gender'] = pet.gender;

    // 이미지 파일이 있는 경우 추가
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // 반려동물 정보 수정
  updatePet(Pet pet, File? imageFile) async {
    var url = Uri.parse('http://127.0.0.1:8000/pet/update');

    var request = http.MultipartRequest('POST', url)
      ..fields['id'] = pet.id
      ..fields['user_id'] = pet.userId
      ..fields['species_type'] = pet.speciesType
      ..fields['species_category'] = pet.speciesCategory
      ..fields['name'] = pet.name
      ..fields['birthday'] = pet.birthday
      ..fields['features'] = pet.features
      ..fields['gender'] = pet.gender;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      await fetchPets(pet.userId); // 업데이트 후 반려동물 목록 새로고침
      return true;
    } else {
      return false;
    }
  }

  // 반려동물 삭제
  deletePet(String petId) async {
    var url = Uri.parse('http://127.0.0.1:8000/pet/delete/$petId');
    try {
      var response = await http.delete(url);

      if (response.statusCode == 200) {
        // 삭제 성공 시 로컬 목록에서도 제거
        pets.removeWhere((pet) => pet.id == petId);
        return true;
      } else {
        // 삭제 실패
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
