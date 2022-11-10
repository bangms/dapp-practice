pragma solidity >= 0.5.0;

contract Adoption {
    address[16] public adopters;

    // 1. Adopting a pet : 애완동물 입양
    // Solidity에서는 함수 매개변수와 출력의 유형을 모두 지정해야 함. 여기서는 petId(정수)를 받아 정수를 반환 
    function adopt(uint petId) public returns (uint) {
        require(petId >= 0 && petId <= 15); // 배열 petId의 범위 인지 확인
        // adoptersSolidity의 배열은 0부터 인덱싱되므로 ID 값은 0에서 15 사이 
        // require()명령문을 사용하여 ID가 ​​범위 내에 있는지 확인

        adopters[petId] = msg.sender; // ID가 범위 내에 있으면 adopters배열을 호출한 주소를 추가
        // 이 함수를 호출한 사람 또는 스마트 계약의 주소는 로 표시됩니다msg.sender

        return petId; // petId확인으로 제공된 것을 반환
    }

    // Retrieving the adopters : 채택자 검색
    function getAdopters() public view returns (address[16] memory) { // 배열 getter는 지정된 키에서 단일 값만 반환
        return adopters;
    }
}