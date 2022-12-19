# dapp-project
programming assignment

## Commit History
### 🕛2022-12-02T13:47:11+09:00
#### update web3interface.js 
- add json2abi function to make importing abi.json easier.

### 🕛2022-12-05T11:08:40+09:00
#### update index.ejs
- change paths for imporing css and js files.

#### 과제 설명 보충
- 선택적 구현의 `intializeRoomShare` 함수는 
**첫날부터 시작해 web3interface.js 의 `getDayOfYear` 함수를 이용하여 함수를 실행한 날짜까지 초기화를 진행하는 함수**입니다.(0 ~ today) 따라서 input의 `day`는 함수를 실행한 당일 날짜입니다.
- 체크아웃 날짜에 대한 질문이 여러번 있었는데, 저는 보통의 경우, 체크아웃이라고 하면 그 날 **숙박**까지를 포함하지않고 그 날 **퇴실**한다고 알고 있었습니다.
따라서 이미 예약된 날짜가 있다면 체크아웃날짜는 그 다음 날이 됩니다.
- `_recommendDate` 함수에서 만약 예약하려는 기간에 여러 예약이 존재한다면 가장 앞부분의 연속된 날짜의 예약만 처리하는 걸로 합니다.  
  그러니까, 두 가지 예약이 존재한다면 앞 부분의 예약만 리턴합니다. 뒷 부분의 예약은 무시합니다.

#### update comments of recommendDate function
- clarify the concept between checkout date and rented date.


### 🕛2022-12-10T11:29:11+09:00
#### 과제 시나리오 부연 설명
본 과제의 구현을 보시면, 온전한 예약 시스템은 아닙니다.  
코드를 보시면 연단위로 예약이 진행되며, 따라서 수동적인 시스템 초기화 작업이 있어야합니다.  
해당 작업이 intializeRoomShare 함수이며 여기에 추가적으로 연도의 수정 작업이 포함되어야 하지만 굳이 거기까진 구현에 넣지 않았습니다.  
이 부분은 제가 제대로 전달드리지 못해 혼란이 있을 수도 있다고 생각합니다.  
우선 이와 관련된 의문 사항은 이 부연 설명으로 갈음하겠습니다.  
추가적인 질문 사항도 언제든지 환영하며, 메일을 통해 전달해주시면 확인 후 답변 드리겠습니다.