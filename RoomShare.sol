// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./IRoomShare.sol";

contract RoomShare {
struct Room {
        uint id;
        string name;
        string location;
        bool isActive;
        uint price;
        address owner;
        bool[] isRented;
    }

    struct Rent {
        uint id;
        uint rId;
        uint checkInDate;
        uint checkOutDate;
        address renter;
    }

    event NewRoom (
        uint256 indexed roomId
    );
    event NewRent (
        uint indexed roomId,
        uint256 indexed rentId
    );
    event Transfer(
      address sender, 
      address recipient, 
      uint amount
    );
    uint public roomId=0;
    uint public rentId=0;

    mapping(uint=>Room) public RoomList;
    mapping(address=>Rent[]) public RentList;
    mapping(uint=>Rent[]) public HistoryList;


  function getMyRents() external view returns(Rent[] memory) {
    /* 함수를 호출한 유저의 대여 목록을 가져온다. */
    address addr = msg.sender;
    Rent[] memory tempRented = RentList[addr];
    return tempRented;
  }

  function getRoomRentHistory(uint _roomId) external view returns(Rent[] memory) {
    /* 특정 방의 대여 히스토리를 보여준다. */
    Rent[] memory rentHistory = HistoryList[_roomId];
    return rentHistory;
  }

  function getAllRooms() external view returns(Room[] memory) {
    Room[] memory allRooms = new Room[](roomId);
    for(uint i=0;i<roomId;i++){
      allRooms[i] = RoomList[i];
    }
    return allRooms;
  }


  function shareRoom( string calldata name, 
                      string calldata location, 
                      uint price ) external {
    /**
     * 1. isActive 초기값은 true로 활성화, 함수를 호출한 유저가 방의 소유자이며, 365 크기의 boolean 배열을 생성하여 방 객체를 만든다.
     * 2. 방의 id와 방 객체를 매핑한다.
     */
    bool[] memory rented = new bool[](365);
    for(uint i=0;i<365;i++) {rented[i] = false;}

    Room memory tempRoom = Room({id : roomId, name: name, location : location, isActive: true, price : price, owner : msg.sender, isRented : rented});
    
    RoomList[roomId] = tempRoom;

    emit NewRoom(roomId++);
  }

  function rentRoom(uint _roomId, uint checkInDate, uint checkOutDate) payable external {
    /**
     * 1. roomId에 해당하는 방을 조회하여 아래와 같은 조건을 만족하는지 체크한다.
     *    a. 현재 활성화(isActive) 되어 있는지
     *    b. 체크인날짜와 체크아웃날짜 사이에 예약된 날이 있는지 
     *    c. 함수를 호출한 유저가 보낸 이더리움 값이 대여한 날에 맞게 지불되었는지(단위는 1 Finney, 10^15 Wei) 
     * 2. 방의 소유자에게 값을 지불하고 (msg.value 사용) createRent를 호출한다.
     * *** 체크아웃 날짜에는 퇴실하여야하며, 해당일까지 숙박을 이용하려면 체크아웃날짜는 그 다음날로 변경하여야한다. ***
     */
     Room memory wantRoom = RoomList[_roomId];
     
     require(wantRoom.isActive == true , "Room is not active");
     
     bool validDay = true;
     for(uint i=checkInDate;i<checkOutDate;i++){
       if(wantRoom.isRented[i] == true){
          validDay = false;
       }
     }
     require(validDay == true, "already Rented in these days");
     require(msg.sender.balance >= msg.value , "wallet is not enough");
     _sendFunds(wantRoom.owner, msg.value);
     _createRent(_roomId, checkInDate, checkOutDate);
     
  }

  function _createRent(uint256 _roomId, uint256 checkInDate, uint256 checkoutDate) internal {
    /**
     * 1. 함수를 호출한 사용자 계정으로 대여 객체를 만들고, 변수 저장 공간에 유의하며 체크인날짜부터 체크아웃날짜에 해당하는 배열 인덱스를 체크한다(초기값은 false이다.).
     * 2. 계정과 대여 객체들을 매핑한다. (대여 목록)
     * 3. 방 id와 대여 객체들을 매핑한다. (대여 히스토리)
     */
    
    Rent memory tempRent = Rent({id : rentId, rId : _roomId, checkInDate : checkInDate, checkOutDate : checkoutDate,renter : msg.sender});
    for(uint i = checkInDate;i<checkoutDate;i++){
      RoomList[_roomId].isRented[i] = true;
    }

    address addr = msg.sender;
    
    RentList[addr].push(tempRent);
    HistoryList[_roomId].push(tempRent);
    
    emit NewRent(_roomId, rentId++);
  }

  function _sendFunds (address owner, uint256 value) internal {
      payable(owner).transfer(value);
  }
  
  

  function recommendDate(uint _roomId, uint checkInDate, uint checkOutDate) external view returns(uint[2] memory) {
    /**
     * 대여가 이미 진행되어 해당 날짜에 대여가 불가능 할 경우, 
     * 기존에 예약된 날짜가 언제부터 언제까지인지 반환한다.
     * checkInDate(체크인하려는 날짜) <= 대여된 체크인 날짜 , 대여된 체크아웃 날짜 < checkOutDate(체크아웃하려는 날짜)
     */
     Rent[] memory tempRent = HistoryList[_roomId];
     uint realCheckInDate;
     uint realCheckOutDate;
     for(uint i=0; i< tempRent.length; i++){
       uint tempCheckInDate = tempRent[i].checkInDate;
       uint tempCheckOutDate = tempRent[i].checkOutDate;
       if(tempCheckOutDate <= checkInDate) continue;
       if(checkOutDate <= tempCheckInDate) continue;
       
       realCheckInDate = tempCheckInDate;
       realCheckOutDate = tempCheckOutDate;
       break;
     }
     uint[2] memory dates;
     dates[0] = realCheckInDate;
     dates[1] = realCheckOutDate;
     return dates;
  }

  // ...
  // optional 1
    // caution: 방의 소유자를 먼저 체크해야한다.
    // isActive 필드만 변경한다.
    function markRoomAsInactive(uint _roomId) external{
      require(msg.sender == RoomList[_roomId].owner, "only owner can inActive room");
      RoomList[_roomId].isActive = false;
    }

    // optional 2
    // caution: 변수의 저장공간에 유의한다.
    // 첫날부터 시작해 함수를 실행한 날짜까지 isRented 필드의 초기화를 진행한다.
    function initializeRoomShare(uint _roomId) external{
    	require(msg.sender == RoomList[_roomId].owner, "only owner can inActive room");
	bool[] memory rented = new bool[](365);
    	for(uint i=0;i<365;i++) {rented[i] = false;}
    	RoomList[_roomId].isRented = rented;
    }

}
