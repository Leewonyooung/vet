import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vet_tab/vm/species_handler.dart';

class MgtSpeciesMgt extends StatelessWidget {
  MgtSpeciesMgt({super.key});

  @override
  Widget build(BuildContext context) {
    final speciesHandler = Get.put(SpeciesHandler());
    speciesHandler.categoryquery();

    return Scaffold(
      appBar: AppBar(
        title: const Text("견종 추가"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 700,
                    height: 400,
                    child: Obx(() {
                      if (speciesHandler.categoryList.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return CupertinoPicker(
                        backgroundColor: const Color.fromARGB(255, 249, 249, 249),
                        itemExtent: 50,
                        scrollController: FixedExtentScrollController(
                          initialItem: speciesHandler.selectedItem.value, 
                        ),
                        onSelectedItemChanged: (value) {
                          speciesHandler.updateSelectedItem(value); 
                        },
                        children: List.generate(
                          speciesHandler.categoryList.length,
                          (index) => Center(
                            child: Text(speciesHandler.categoryList[index].category),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (speciesHandler.categoryList.isEmpty) {
                return const Text('Loading...');
              } else {
                return Text(
                  '견종: ${speciesHandler.categoryList[speciesHandler.selectedItem.value].category}',
                  style: const TextStyle(fontSize: 20),
                );
              }
            }),
            SizedBox(
              width: 700,
              child: TextField(
                controller: speciesHandler.speciesController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed:() {
                    speciesHandler.categoryInsert(speciesHandler.speciesController.text);
                    },
                    icon: Icon(Icons.add),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}