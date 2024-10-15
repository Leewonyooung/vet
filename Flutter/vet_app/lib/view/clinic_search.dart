
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
          padding: EdgeInsets.only(left:12.0),
          child: Icon(Icons.search_outlined, size: 25,),
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
      ),
    ),
    body: GetBuilder<FavoriteHandler>(
      builder: (_) {
        return Column(
          children: [
            Expanded(
              child: Obx(() {
                return Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height:MediaQuery.of(context).size.height / 1.4,
                      child: ListView.builder(
                        itemCount: vmHandler.clinicSearch.length,
                        itemBuilder: (context, index) {
                          final clinic = vmHandler.clinicSearch;
                          return GestureDetector(
                            onTap: () async{
                              await vmHandler.resetTextfield();
                              await vmHandler.getAllClinic();
                              vmHandler.updateCurrentIndex(
                                  clinic[index].id);
                              vmHandler.searchbarController.clear();
                              vmHandler.getAllClinic();
                              Get.to(() => ClinicInfo(), arguments: [
                                clinic[index].id,
                              ]);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: MediaQuery.of(context).size.height / 8,
                                decoration: BoxDecoration(
                                  color: index %3 ==1 ?Theme.of(context).colorScheme.primaryContainer:index %3 ==2 
                                  ?Theme.of(context).colorScheme.secondaryContainer:
                                  Theme.of(context).colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(15),
                                  // border: Border.all(color: Colors.black)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image.network(
                                              'http://127.0.0.1:8000/clinic/view/${clinic[index].image}',
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.1,
                                                  fit: BoxFit.cover,),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left:8.0,top: 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  clinic[index].name,
                                                  style: TextStyle(
                                                    color: index % 3 == 1 ?Theme.of(context).colorScheme.primary:
                                                    index % 3 == 2 ?Theme.of(context).colorScheme.secondary : 
                                                    Theme.of(context).colorScheme.tertiary,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  clinic[index].address,
                                                  style:TextStyle(
                                                    color: index % 3 == 1 ?Theme.of(context).colorScheme.primary:
                                                    index % 3 == 2 ?Theme.of(context).colorScheme.secondary : 
                                                    Theme.of(context).colorScheme.tertiary,
                                                    // fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:TextOverflow.ellipsis,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              // }
            }),
            ),
          ],
        );
      },
    ));
  }
}
