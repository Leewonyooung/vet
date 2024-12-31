import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/clinic_info.dart';
import 'package:vet_app/vm/favorite_handler.dart';

class ClinicSearch extends StatelessWidget {
  ClinicSearch({super.key});

  final FavoriteHandler vmHandler = Get.find();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.1,
        title: SearchBar(
          leading: Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.03),
            child: Icon(
              Icons.search_outlined,
              size: screenWidth * 0.07,
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
          backgroundColor: WidgetStateProperty.all(Colors.grey[200]),
          elevation: WidgetStateProperty.all(4),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
            ),
          ),
        ),
      ),
      body: GetBuilder<FavoriteHandler>(builder: (_) {
        return Obx(() {
          return ListView.builder(
            itemCount: vmHandler.clinicSearch.length,
            itemBuilder: (context, index) {
              final clinic = vmHandler.clinicSearch[index];
              return GestureDetector(
                onTap: () async {
                  await vmHandler.resetTextfield();
                  await vmHandler.getAllClinic();
                  await vmHandler.updateCurrentIndex(clinic.id);
                  await vmHandler.getClinicDetail();
                  vmHandler.searchbarController.clear();
                  Get.to(
                    () => ClinicInfo(),
                    arguments: [clinic.id],
                  );
                },
                child: Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.01,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.03),
                          child: Container(
                            width: screenWidth * 0.2,
                            height: screenWidth * 0.2,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.rectangle,
                            ),
                            child: CachedNetworkImage(
                              imageUrl:
                                  "${vmHandler.server}/clinic/view/${clinic.image}",
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clinic.name,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: screenWidth * 0.01),
                              Text(
                                clinic.address,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: screenWidth * 0.04,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: screenWidth * 0.05,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
      }),
    );
  }
}
