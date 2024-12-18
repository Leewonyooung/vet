import 'package:cached_network_image/cached_network_image.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    ReservationHandler reservationHandler = Get.put(ReservationHandler());
    PetHandler petHandler = Get.find();
    var value = Get.arguments ?? "__"; // clinicid = value

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '병원 정보',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: GetBuilder<FavoriteHandler>(builder: (_) {
        final result = vmHandler.clinicDetail[0];
        vmHandler.searchFavoriteClinic(
            vmHandler.getStoredEmail(), value[0]); // 즐겨찾기 여부 검색
        reservationHandler.reservationButtonMgt(value[0]); // 예약 가능 여부 검색

        return Obx(() {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClinicImage(result, screenWidth, screenHeight),
                _buildClinicInfo(
                    result, vmHandler, value[0], context, screenWidth),
                _buildClinicDescription(result, screenWidth),
                _buildActionButtons(
                  result,
                  vmHandler,
                  reservationHandler,
                  petHandler,
                  context,
                  screenWidth,
                ),
              ],
            ),
          );
        });
      }),
    );
  }

  Widget _buildClinicImage(
      Clinic result, double screenWidth, double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.3,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: CachedNetworkImage(
          imageUrl: "${vmHandler.server}/clinic/view/${result.image}",
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.error,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildClinicInfo(Clinic result, FavoriteHandler favoriteHandler,
      String value, BuildContext context, double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  result.name,
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  favoriteHandler.favoriteIconValue.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: favoriteHandler.favoriteIconValue.value
                      ? Colors.red
                      : Colors.grey,
                  size: screenWidth * 0.08,
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
          SizedBox(height: screenWidth * 0.02),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey),
              SizedBox(width: screenWidth * 0.02),
              Text(
                "${result.startTime}~${result.endTime}",
                style:
                    TextStyle(color: Colors.grey, fontSize: screenWidth * 0.04),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Text(
                  result.address,
                  style: TextStyle(
                      color: Colors.grey, fontSize: screenWidth * 0.04),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.04),
          ElevatedButton.icon(
            icon: const Icon(Icons.map),
            label: const Text("지도에서 보기"),
            onPressed: () async {
              await favoriteHandler.getClinicDetail();
              await vmHandler.checkLocationPermission();
              await favoriteHandler.maploading(
                favoriteHandler.clinicDetail[0].latitude,
                favoriteHandler.clinicDetail[0].longitude,
              );
              Get.to(() => ClinicLocation(), arguments: [result.id]);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicDescription(Clinic result, double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "병원 소개",
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            result.introduction,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      Clinic result,
      FavoriteHandler favoriteHandler,
      ReservationHandler reservationHandler,
      PetHandler petHandler,
      BuildContext context,
      double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              if (!chatsHandler.isLoggedIn()) {
                Get.to(() => Login());
              } else {
                chatsHandler.currentClinicId.value = result.id;
                chatsHandler.roomName.clear();
                chatsHandler.lastChatsMap.clear();
                await chatsHandler.makeChatRoom();
                var tempPath = await chatsHandler.firstChatRoom(
                  result.id,
                  result.name,
                  result.image,
                );
                if (tempPath == null || tempPath.isEmpty) return;
                await chatsHandler.queryChat();
                Get.to(() => ChatView(), arguments: [tempPath, result.name]);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightGreen.shade300,
              minimumSize: Size(double.infinity, screenWidth * 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              '상담하기',
              style: TextStyle(fontSize: screenWidth * 0.045),
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          Visibility(
            visible: reservationHandler.resButtonValue.value,
            child: ElevatedButton(
              onPressed: () async {
                if (!vmHandler.isLoggedIn()) {
                  Get.to(() => Login());
                } else {
                  await petHandler.makeBorderlist();
                  Get.to(() => MakeReservation(), arguments: [
                    reservationHandler.canReservationClinic[0].id,
                    reservationHandler.canReservationClinic[0].name,
                    reservationHandler.canReservationClinic[0].latitude,
                    reservationHandler.canReservationClinic[0].longitude,
                    reservationHandler.canReservationClinic[0].time,
                    reservationHandler.canReservationClinic[0].address,
                  ]);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade300,
                minimumSize: Size(double.infinity, screenWidth * 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                '예약하기',
                style: TextStyle(fontSize: screenWidth * 0.045),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showSnackBar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
