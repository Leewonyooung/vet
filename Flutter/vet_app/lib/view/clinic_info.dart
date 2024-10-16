import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/clinic.dart';
import 'package:vet_app/view/chat_view.dart';
import 'package:vet_app/view/clinic_location.dart';
import 'package:vet_app/view/login.dart';
import 'package:vet_app/view/make_reservation.dart';
import 'package:vet_app/vm/chat_handler.dart';
import 'package:vet_app/vm/favorite_handler.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/reservation_handler.dart';

class ClinicInfo extends StatelessWidget {
  ClinicInfo({super.key});

  final FavoriteHandler vmHandler = Get.find();
  final ChatsHandler chatsHandler = Get.find();

  @override
  Widget build(BuildContext context) {
    ReservationHandler reservationHandler = Get.put(ReservationHandler());
    PetHandler petHandler = Get.find();
    var value = Get.arguments ?? "__"; // clinicid = value

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '병원 정보',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: GetBuilder<FavoriteHandler>(
        builder: (_) {
          final result = vmHandler.clinicDetail[0];
          vmHandler.searchFavoriteClinic(vmHandler.getStoredEmail(),value[0]); // 즐겨찾기 여부 검색 : 즐겨찾기 버튼 관리
          reservationHandler.reservationButtonMgt(value[0]); // 예약 가능여부 검색 : 예약버튼 활성화
            return Obx(() {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildClinicImage(result),
                    _buildClinicInfo(
                        result, vmHandler, value[0], context),
                    _buildClinicDescription(result),
                    _buildActionButtons(result, vmHandler,
                        reservationHandler, petHandler, context),
                  ],
                ),
              );
            }
          );
        }
      )
    );
  }

  // 이미지
  _buildClinicImage(Clinic result) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: Image.network(
          'http://127.0.0.1:8000/clinic/view/${result.image}',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, size: 100),
        ),
      ),
    );
  }

  // 정보
  _buildClinicInfo(Clinic result, FavoriteHandler favoriteHandler,
      String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  result.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: favoriteHandler.favoriteIconValue.value
                    ? const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 30,
                      )
                    : const Icon(
                        Icons.favorite_border,
                        size: 30,
                      ),
                onPressed: () async {
                  await favoriteHandler.favoriteIconValueMgt(
                      favoriteHandler.getStoredEmail(), value);
                  if (favoriteHandler.favoriteIconValue.value) {
                    showSnackBar(
                      '추가성공',
                      '즐겨찾기에 등록되었습니다.',
                      Colors.green,
                    );
                  } else {
                    showSnackBar(
                      '삭제',
                      '즐겨찾기가 삭제되었습니다.',
                      Colors.red,
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text("${result.startTime}~${result.endTime}",
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.address,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.map),
            label: const Text("지도에서 보기"),
            onPressed: () async {
              await favoriteHandler.getClinicDetail();
              await vmHandler.checkLocationPermission();
              await favoriteHandler.maploading(
                  favoriteHandler.clinicDetail[0].latitude,
                  favoriteHandler.clinicDetail[0].longitude);
              Get.to(() => ClinicLocation(), arguments: [result.id]);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }


  // introduction
  _buildClinicDescription(Clinic result) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "병원 소개",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.introduction,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  _buildActionButtons(
      Clinic result,
      FavoriteHandler favoriteHandler,
      ReservationHandler reservationHandler,
      PetHandler petHandler,
      BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              if(chatsHandler.isLoggedIn() ==false){
                Get.to(()=>Login());
              }else{
              chatsHandler.currentClinicId.value = result.id;
              await chatsHandler.makeChatRoom();
              var tempPath = await chatsHandler.firstChatRoom(result.id, result.image);
              await chatsHandler.queryChat();
              Get.to(() => ChatView(), arguments: [
                tempPath,
                favoriteHandler.clinicDetail[0].name,
              ]);}
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightGreen.shade300,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('상담하기', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 16),
          Visibility(
            visible: reservationHandler.resButtonValue.value,
            child: ElevatedButton(
              onPressed: () async {
                if (vmHandler.isLoggedIn() == false) {
                  Get.to(() => Login());
                } else {
                  await petHandler.makeBorderlist();
                  Get.to(() => MakeReservation(), arguments: [
                    reservationHandler.canReservationClinic[0].id,
                    reservationHandler.canReservationClinic[0].name,
                    reservationHandler.canReservationClinic[0].latitude,
                    reservationHandler.canReservationClinic[0].longitude,
                    reservationHandler.canReservationClinic[0].time,
                    reservationHandler.canReservationClinic[0].address
                  ]);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade300,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                '예약하기',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  showSnackBar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
