import 'dart:convert';

import 'package:vet_app/model/clinic.dart';
import 'package:vet_app/vm/user_handler.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class ClinicHandler extends UserHandler{
  final clinics = <Clinic>[].obs;

  @override
  void onInit() async{
    super.onInit();
    await getAllClinic();
  }

  getAllClinic() async{
    var url = Uri.parse("http://127.0.0.1:8000/clinic/");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    clinics.value = result.map((e) => Clinic.fromMap(e),).toList();
  }

  

}