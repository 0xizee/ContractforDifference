// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
error bobHasSend();
error onlyalice();
error somethingWrongHappend();
error onlybob();
contract contractForDifference{
    address payable immutable  alice;
    address payable immutable  bob;
    int futurePrice;
    bool bobSend;
    uint timeStamp;
    AggregatorV3Interface internal priceFeed;

    modifier onlyAlice(){
        if(msg.sender != alice) revert onlyalice();
        _;
    }

    modifier onlyBob(){
        if(msg.sender != bob) revert onlybob();
        _;
    }

    constructor (address _alice , address _bob , int _futurePrice){
        alice = payable(_alice);
        bob = payable(_bob);
        futurePrice = _futurePrice * 10 ** 7;
        timeStamp = block.timestamp;
        priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    }

    function aliceSendMoney() public payable{}

    function bobSendMoney() public payable {
        bobSend = true;
    }

    function removeifBobDosentSend() public payable onlyAlice {
        if(bobSend){
           revert bobHasSend(); 
        }
        (bool sucess ,) = payable(msg.sender).call{value:address(this).balance}("");
        if(!sucess) revert somethingWrongHappend();
    }

     function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
     }
    function closeCfd() public payable onlyAlice{
        uint thrity_days = 100 seconds + timeStamp;
        require(block.timestamp >= thrity_days,"CFD_CLOSES_AFTER30_DAYS");
        int price = getLatestPrice();
        if(price > futurePrice){
            (bool sucess , ) = alice.call{value:9000000000000000}("");
            if(!sucess) revert somethingWrongHappend();
        }else if(price < futurePrice){  
             (bool sucess,) = alice.call{value:11000000000000000}("");
            if(!sucess) revert somethingWrongHappend(); 
        }else{
             (bool sucess , ) = alice.call{value:20000000000000000}("");
            if(!sucess) revert somethingWrongHappend();
        }
    }

    function withdrawFromBob() external payable onlyBob{
         uint thrity_days = 100 seconds+ timeStamp;
        require(block.timestamp >= thrity_days,"CFD_CLOSES_AFTER30_DAYS");
        payable(msg.sender).transfer(address(this).balance);
    }
}