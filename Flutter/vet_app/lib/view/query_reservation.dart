import 'package:flutter/material.dart';
import 'package:vet_app/vm/pet_handler.dart';

class QueryReservation extends StatelessWidget {
  QueryReservation({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('예약내역'),
      ),
    );
  }
}
