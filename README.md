# 멍스파인더


## EER
<img width="1083" alt="mysql_EER" src="https://github.com/user-attachments/assets/50eea10b-75c9-44f9-856b-beb5e81e48a1">
<img width="1269" alt="chat_EER" src="https://github.com/user-attachments/assets/943ea205-2f4a-4658-8e7e-19c528a78efb">

## ⚙ Organization

|    역할   |           Name           | 
|  :-----: | :----------------------: | 
|    팀장   | <center> **이원영** </center> |
|    팀원   | <center> 신정섭  </center> | 
|    팀원   | <center> 안창빈  </center> | 
|    팀원   | <center> 이종남  </center> | 
|    팀원   | <center> 정정영  </center> |


## 디자인 패턴(MVVM)

<img width="366" alt="all_tree" src="https://github.com/user-attachments/assets/565f5711-48a1-4c6f-8452-47120bbc0664">


## API
<img width="1184" alt="스크린샷 2024-10-17 오후 7 01 35" src="https://github.com/user-attachments/assets/59229efc-8a30-4089-b98e-f454e83d7850">

### Packages / 사용한 패키지

```
  # 라우팅 및 상태 관리
  get: ^4.6.6

  # Firebase 연동
  firebase_core: ^3.6.0
  cloud_firestore: ^5.4.3
  firebase_storage: ^12.3.2

  # 네비게이션 바
  persistent_bottom_nav_bar: ^6.2.1

  # http 통신
  http: ^1.2.2

  # image picker
  image_picker: ^1.1.2

  # 위도경도
  geocoding: ^3.0.0
  geolocator: ^13.0.1

  # map
  flutter_map: ^7.0.2
  latlong2: ^0.9.1

  # 사진 업로드시 경로 가져오기
  path_provider: ^2.0.11

  # 구글 로그인 연동
  google_sign_in: ^6.2.1
  firebase_auth: ^5.3.1

  # 로그인 정보 앱에 쓰기
  get_storage: ^2.1.1

  # googlemap
  google_maps_flutter: ^2.9.0

  # 구글맵 route decode
  flutter_polyline_points: ^2.1.0

  # Date Format
  intl: ^0.19.0
```


### 멍스파인더 코딩

```
반려동물 커뮤니티 앱들은 몇몇 존재했지만 반려동물 병워과 연결되는 앱은 없는걸로 보여서 개발해보기로 결정했다.
계획과 변동 된 점 : 진료를 받고 후기를 작성하고 별점주기, 병원 별 치료가능한 시술 목록 및 시술 단가는 빼기로 결정
```


### 데모 시연



## Progress

~ 10.02. 

  주제선정 및 프로젝트 구상

  10.03. ~ 10.04.

  프로젝트 EER 구상 및 역할 분담 및 기획 발표

  10.07 ~ 10.08.

  진행중 EER 수정, 부족한 기능 추가
  사용할 패키지 취합
  채팅구현을 위한 firebase 연동 완료
  mysql 서버 구축 및 라우터 구현
  구글 맵 연동 완료 (lat, lng 연동 필요)
  예약 쿼리 설계
  구글 auth 연동 
  

 10.10 ~ 10.11.

 
  채팅 전반적인 구현 완료 (채티방에서 마지막 채팅을 보여주는 것은 되나 realtime 연동이 안됨)
  유저 별 반려동물 등록 구현
  예약 기능 구현
  병원 관리자 페이지 구현중~
   
  10.14 ~ 10.15.
  
  채팅방에 마지막 채팅 보여주기 기능 에러 발견하여 수정
  관리자 페이지 완료
  핸들러 분리 후 충돌 수정
  앱 UI수정

  10.16 ~ 10.17.

  최종 코드 확인 및 코드 리뷰
  발표 준비 및 document 작업


## Contribution

  요약
  - ..
 
  Python
  -  이원영 : 라우터 설계
  -  신정섭 : //
  -  안창빈 : //
  -  이종남 : //
  -  정정영 : //
  
  View
  -  이원영 : 채팅 방, 채팅 목록, 스플래시, persitent_nav_bar를 통한 탭바 페이지, 컨트롤러를 통한 페이지 상태 관리 
  -  신정섭 : 병원 검색 페이지, 병원 상세 페이지,  google map을 활용한 지도페이지, 마이페이지
  -  안창빈 : //
  -  이종남 : //
  -  정정영 : //

  View Model
  -  이원영 :
     GetXController 설계, 모듈화 및 분리 앱, 태블릿 ChatsController 
  -  신정섭 : app locationController
  -  안창빈 : //
  -  이종남 : //
  -  정정영 : //
 
    
