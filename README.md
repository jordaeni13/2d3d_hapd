# 2d3d_hapd
2d3d_hapd

Xcode version 14.3d 

iOS 16 >= for the deploymenet

- [x] 사진 찍기
- [x] 찍은 사진을 MiDaS로 convert하여 저장하기
- [ ] 갤러리 기능 구현 X(제스처 허용 구역 설정하고 스와이프로 사진 index 바꾸는 기능까지)
- [x] 색깔에 따른 진동

--------

안녕하세요.

제주과학고등학교 전람회 작품 HapD 입니다.


여태까지 시각장애인은 사진이라는 매체를 접할 수 있는 방법이 없었습니다. 이에 대한 대안으로 제시된 것도 결국 물체의 인식을 통한 사진 속 물체에 대한 언어적 묘사였고, 이는 사진이라는 매체를 우리가 접할 때 직관적으로 접하는 것과 다르게 사진을 추상적인 매체로밖에 받아들이지 못한다는 한계를 갖고 있습니다. 그러나, 만약 이러한 사진을 촉감적 묘사를 통해 시각장애인이 접할 수 있도록 해준다면 보다 직관적인 방법으로 사진을 받아들이고, 비장애인과 함께 사진이라는 매체를 더욱 효과적으로 즐길 수 있게 될 것이라고 생각합니다.


이때, 촉감적 묘사를 통해 시각장애인에게 사진을 묘사할 수 있는 방법 중 가장 직관적인 방법은, 사진의 깊이에 따라 진동의 세기를 다르게 하여 사진이 어떤 식으로 구성됐는가를 전달해주는 방법이라고 생각합니다. 이에 따라, 텐서플로우 모델 MiDaS를 이용하여 촬영한 사진을 depth에 따라 세기가 다르게 나타나는 흑백 사진을 만들고, 이렇게 만든 흑백 사진을 기기 내 갤러리에 저장하는 과정과, 이렇게 저장된 사진을 기기 내 갤러리에서 다시 불러온 뒤 depth에 따라 누른 지점의 햅틱이 다르게 나타나는 기능을 구현한 앱을 만들고자 했습니다.


이러한 과정은 앱 실행 후 카메라 버튼을 눌러 사진을 찍은 뒤, 왼쪽 상단에 있는 버튼을 눌러 메인 화면으로 돌아가서, 왼쪽 하단에 있는 갤러리 아이콘을 누른 뒤 MiDaS를 통해 흑백으로 변환된 사진을 고르게 되면 메인 화면에 사진이 불러와짐으로써 이루어집니다. 이후, 이렇게 메인 화면에 불러와진 사진은 햅틱 기능이 있는 기기에 한정해서 밝기에 따른 진동 세기가 느껴지게 될 것입니다.
