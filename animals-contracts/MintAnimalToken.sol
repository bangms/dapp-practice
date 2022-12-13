// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// NFT는 ERC721이다 라고 생각해도 무방함 

import "SaleAnimalToken.sol";

contract MintAnimalToken is ERC721Enumerable { // 컨트랙트 생성
    constructor() ERC721("h662Animals", "HAS") {} // 컨트랙트가 실행될 때 한번 실행 (name, symbol) 두가지가 필요함 

    SaleAnimalToken public saleAnimalToken;

    // animalTokenId => animalTypes // 토큰 아이디 입력하면 타입이 나온다는 뜻
    mapping(uint256 => uint256) public animalTypes;

    struct AnimalTokenData {
        uint256 animalTokenId;
        uint256 animalType;
        uint256 animalPrice;
    }

    // 민트 함수
    function mintAnimalToken() public { // 함수 범위 public으로 설정
        // totalSupply() 발행된 NFT 갯수 // 유일한 값
        uint256 animalTokenId = totalSupply() + 1;

        // block.timestamp 함수 실행 시간 / msg.sender 함수 실행한 사람 / animalTokenId = NFT id / 
        // 1부터 5까지 랜덤으로 생성 keccak256 알고리즘 사용 // abi.encodePacked byte 값 생성 바뀌는 값을 입력(현재시간, 실행하는 사람, 토큰 아이디) 겹치지 않는 값 생성
        // 솔리디티에서 랜덤값을 생성하는 방법 
        uint256 animalType = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, animalTokenId))) % 5 + 1;

        // 1번부터 5번까지의 값이 들어가게 됨
        animalTypes[animalTokenId] = animalType;

        // msg.sender 민팅하는 사람 // erc721에서 제공하는 _mint 함수 
        _mint(msg.sender, animalTokenId);
        // ownerOf 에 토큰아이디 넣어서 입력시 msg.sender의 address를 알 수 있음
    }

    function getAnimalTokens(address _animalTokenOwner) view public returns (AnimalTokenData[] memory) {
        uint256 balanceLength = balanceOf(_animalTokenOwner);

        require(balanceLength != 0, "Owner did not have token.");

        AnimalTokenData[] memory animalTokenData = new AnimalTokenData[](balanceLength);

        for(uint256 i = 0; i < balanceLength; i++) {
            uint256 animalTokenId = tokenOfOwnerByIndex(_animalTokenOwner, i);
            uint256 animalType = animalTypes[animalTokenId];
            uint256 animalPrice = saleAnimalToken.getAnimalTokenPrice(animalTokenId);

            animalTokenData[i] = AnimalTokenData(animalTokenId, animalType, animalPrice);
        }

        return animalTokenData;
    }

    function setSaleAnimalToken(address _saleAnimalToken) public {
        saleAnimalToken = SaleAnimalToken(_saleAnimalToken);
    }
}