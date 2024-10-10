import 'package:flutter/material.dart';

class MgtHome extends StatelessWidget {
  const MgtHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    //
                  },
                  child: const Text('Create Clinic account')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    //
                  },
                  child: const Text('Create Species')),
            ),
          ],
        ),
      ),
    );
  }
}
