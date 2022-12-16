// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "MintAnimalToken.sol"; // 민트 함수 사용

contract SaleAnimalToken {
    MintAnimalToken public mintAnimalTokenAddress; 

    // MintAnimalToken를 deploy(배포) 한 주소값이 나오게 되는데 그 주소를 담기
    constructor (address _mintAnimalTokenAddress) {
        mintAnimalTokenAddress = MintAnimalToken(_mintAnimalTokenAddress);
    }

    // 가격들을 관리하는 mapping
    // 토큰 아이디를 입력하면 가격 출력 (uint256(토큰아이디) => uint256(가격)) 
    mapping(uint256 => uint256) public animalTokenPrices;

    // 프론트에서 이 배열을 이용해서 판매중인 토큰을 나타낼 수 있도록
    uint256[] public onSaleAnimalTokenArray;

    // 어떤 것을 팔건지(_animalTokenId), 얼마에 팔건지(_price)
    function setForSaleAnimalToken(uint256 _animalTokenId, uint256 _price) public {
        // 다른 사람이 아닌 해당 주인이 판매등록을 해야하기 때문에 주인 확인
        // 토큰 주인의 주소를 출력
        address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId);

        // 주인이 맞는지 확인 // 지금 이 함수를 실행하는 사람이 토큰 주인이 맞는지 확인 // 맞다면 그냥 넘어가고 아니라면 메시지를 출력
        require(animalTokenOwner == msg.sender, "Caller is not animal token owner.");
        require(_price > 0, "Price is zero or lower."); // 가격이 0보다 큰지 0원보다 작은 값으로 판매등록을 할 수 없도록
        // 값이 있거나 0원이거나 두가지 경우가 있는데 값이 이미 있는 경우이면 이미 판매등록이 되었다는 뜻이므로 에러 메시지 출력
        require(animalTokenPrices[_animalTokenId] == 0, "This animal token is already on sale.");
        // isApprovedForAll(주인, saleAnimalToken의 smart contract) // animalTokenOwner(주인)이 판매계약서에 판매권한을 넘겼는지 확인
        // smart contract가 파일이라서 이상한 smart contract에 코인을 보내버렸을 경우 코인이 묶여버려서 찾을 수 없는 경우가 발생하기 때문에 확인
        require(mintAnimalTokenAddress.isApprovedForAll(animalTokenOwner, address(this)), "Animal token owner did not approve token.");

        animalTokenPrices[_animalTokenId] = _price; 

        onSaleAnimalTokenArray.push(_animalTokenId); // 판매중인 토큰 아이디 배열에 넣어주기
    }

    // 구매함수
    function purchaseAnimalToken(uint256 _animalTokenId) public payable { // payable 을 붙여야 실제로 돈이 왔다갔다하는 함수를 만들 수 있음
        // animalTokenPrices mapping에 담겨있는 값 꺼내오기
        uint256 price = animalTokenPrices[_animalTokenId];
        // 주인의 주소값 불러오기
        address animalTokenOnwer = mintAnimalTokenAddress.ownerOf(_animalTokenId);

        // 가격이 0보다 큰 경우
        require(price > 0, "Animal token not sale.");
        // msg.value 이 함수를 실행할 때 보내는 매틱의 양
        require(price <= msg.value, "Caller sent lower than price.");
        // 주인이 아니어야 구입 가능
        require(animalTokenOnwer != msg.sender, "Caller is animal token owner.");

        // 아래 코드를 위해서 함수 정의할 때 payable을 넣어주어야 함
        // 토큰 주인에게 돈을 보내줌
        payable(animalTokenOnwer).transfer(msg.value);
        // nft를 보내줌 // 보내는 사람, 받는 사람, 토큰 아이디
        mintAnimalTokenAddress.safeTransferFrom(animalTokenOnwer, msg.sender, _animalTokenId);

        // animalTokenPrices mapping 에서 해당 토큰 제거
        animalTokenPrices[_animalTokenId] = 0;

        // onSaleAnimalTokenArray 에서 해당 토큰 제거
        for(uint256 i = 0; i < onSaleAnimalTokenArray.length; i++) {
            // 위에서 animalTokenPrices에 있는 해당 토큰의 가격을 0으로 초기화 시킴
            // onSaleAnimalTokenArray에서 가격이 0인 토큰을 찾는 것
            if(animalTokenPrices[onSaleAnimalTokenArray[i]] == 0) {
                // 현재 0원인 토큰과 맨뒤의 토큰을 교체하고 맨뒤의 토큰을 삭제
                onSaleAnimalTokenArray[i] = onSaleAnimalTokenArray[onSaleAnimalTokenArray.length - 1];
                onSaleAnimalTokenArray.pop();
            }
        }
    }

    // 판매중인 토큰 배열의 길이를 출력하는 함수
    // view 읽기 전용 // return 값이 있는 함수
    function getOnSaleAnimalTokenArrayLength() view public returns (uint256) {
        return onSaleAnimalTokenArray.length;
    }

    function getAnimalTokenPrice(uint256 _animalTokenId) view public returns (uint256) {
        return animalTokenPrices[_animalTokenId];
    }
}