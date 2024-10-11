import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/navigation.dart';
import 'package:vet_app/view/query_reservation.dart';

class ReservationComplete extends StatelessWidget {
  ReservationComplete({super.key});
  var value = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('예약 확정',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
            ),
            // Text("감사합니다\n${id} 고객님\n${clinic_id}의 예약이\n확정되셨습니다.")
            // Row(
            //   children: [
            //     Icon(Icons.arrow_forward),
            //     Text(time)
            //   ],
            // ),
            // Text('찾아오시는길',
            // style: TextStyle(
            //   fontSize: 11,
            //   fontWeight: FontWeight.bold
            // ),),
            // Text('주소: ${address}',),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => Get.to(QueryReservation()), 
                  child: const Text('예약내역'),
                ),
                ElevatedButton(
                  onPressed: () => Get.to(Navigation()), 
                  child: const Text('홈으로'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
