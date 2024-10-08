import 'package:flutter/material.dart';
import 'package:vet_app/vm/reservation_handler.dart';

class Reservation extends StatelessWidget {
  Reservation({super.key});
  
  final vmHnadler = ReservationHandler();
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.local_hospital),Text('긴급예약')],),
        actions: [
          IconButton(
            onPressed: () {
              
            },
            icon: const Icon(Icons.favorite_border_outlined)),
          IconButton(
            onPressed: () {
              
            },
            icon: const Icon(Icons.account_circle_outlined)),
        ],
      ),
    );
  }
}