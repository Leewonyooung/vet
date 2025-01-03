class Pet {
  String id;
  String userId;
  String speciesType;
  String speciesCategory;
  String name;
  String birthday;
  String features;
  String gender;
  String? image;

  Pet({
    required this.id,
    required this.userId,
    required this.speciesType,
    required this.speciesCategory,
    required this.name,
    required this.birthday,
    required this.features,
    required this.gender,
    this.image,
  });
}
