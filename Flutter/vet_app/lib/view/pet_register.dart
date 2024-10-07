import 'package:flutter/material.dart';

class PetRegister extends StatefulWidget {
  const PetRegister({super.key});

  @override
  _PetRegisterState createState() => _PetRegisterState();
}

class _PetRegisterState extends State<PetRegister> {
  final _formKey = GlobalKey<FormState>();

  // 폼 필드에 대한 컨트롤러
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  // 드롭다운 값 관리
  String? _speciesType;
  String? _speciesCategory;
  String? _gender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('반려동물 등록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 등록번호 입력
              TextFormField(
                controller: _registrationNumberController,
                decoration: const InputDecoration(
                  labelText: '등록번호',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '등록번호를 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 사용자 ID 입력
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: '사용자 ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '사용자 ID를 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 동물 종류 선택 (species_type)
              DropdownButtonFormField<String>(
                value: _speciesType,
                decoration: const InputDecoration(
                  labelText: '동물 종류',
                  border: OutlineInputBorder(),
                ),
                items: ['강아지'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _speciesType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '동물 종류를 선택하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 동물 카테고리 선택 (species_category)
              DropdownButtonFormField<String>(
                value: _speciesCategory,
                decoration: const InputDecoration(
                  labelText: '동물 카테고리',
                  border: OutlineInputBorder(),
                ),
                items: ['허스키', '샤모예드', '시바', '푸들', '비숑'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _speciesCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '동물 카테고리를 선택하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 이름 입력
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 생년월일 입력
              TextFormField(
                controller: _dateOfBirthController,
                decoration: const InputDecoration(
                  labelText: '생년월일',
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '생년월일을 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 특징 입력
              TextFormField(
                controller: _featuresController,
                decoration: const InputDecoration(
                  labelText: '특징',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 성별 선택
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: '성별',
                  border: OutlineInputBorder(),
                ),
                items: ['암컷', '수컷'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '성별을 선택하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 이미지 URL 입력
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: '이미지 URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 제출 버튼
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // 추후에 DB 저장 로직 추가 예정
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('반려동물이 등록되었습니다.')),
                    );
                  }
                },
                child: const Text('등록'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _registrationNumberController.dispose();
    _userIdController.dispose();
    _nameController.dispose();
    _dateOfBirthController.dispose();
    _featuresController.dispose();
    _imageController.dispose();
    super.dispose();
  }
}
