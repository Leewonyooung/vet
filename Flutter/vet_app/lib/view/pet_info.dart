import 'package:flutter/material.dart';
import 'package:vet_app/model/pet.dart';

class PetInfo extends StatelessWidget {
  final Pet pet; // 반려동물 정보 받기

  const PetInfo({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${pet.name} 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이름: ${pet.name}', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Text('Id: ${pet.id}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('종류: ${pet.speciesType}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('성별: ${pet.gender}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('특징: ${pet.features}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('생일: ${pet.birthday}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Image.network(
              'http://127.0.0.1:8000/pet/uploads/${pet.image}',
              height: 200,
              width: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 200); // 이미지 로드 실패 시
              },
            ),
          ],
        ),
      ),
    );
  }
}
