import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/clinic_info.dart';
import 'package:vet_app/vm/favorite_handler.dart';

class ClinicSearch extends StatelessWidget {
  ClinicSearch({super.key});

  final FavoriteHandler vmHandler = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: SearchBar(
          leading: const Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Icon(
              Icons.search_outlined,
              size: 25,
              color: Colors.grey,
            ),
          ),
          controller: vmHandler.searchbarController,
          onChanged: (value) {
            vmHandler.searchbarController.text = value;
            if (value.isNotEmpty) {
              vmHandler.searchbarClinic();
            } else {
              vmHandler.getAllClinic();
            }
          },
          hintText: "병원 이름을 검색하세요",
          backgroundColor: WidgetStateProperty.all(
            Colors.grey[200],
          ),
          elevation: WidgetStateProperty.all(0),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
      body: GetBuilder<FavoriteHandler>(
        builder: (_) {
          return Obx(() {
            return ListView.builder(
              itemCount: vmHandler.clinicSearch.length,
              itemBuilder: (context, index) {
                final clinic = vmHandler.clinicSearch[index];
                return GestureDetector(
                  onTap: () async {
                    await vmHandler.resetTextfield();
                    await vmHandler.getAllClinic();
                    vmHandler.updateCurrentIndex(clinic.id);
                    vmHandler.searchbarController.clear();
                    Get.to(() => ClinicInfo(), arguments: [clinic.id]);
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              'http://127.0.0.1:8000/clinic/view/${clinic.image}',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clinic.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  clinic.address,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          });
        },
      ),
    );
  }
}
