pragma solidity ^0.4.0;

import "./SafeMath.sol";
import "./CryptoRent.sol";

contract Escrow is CryptoRent{
    using SafeMath for uint256;


    enum State { AWAITING_PAYMENT, AWAITING_APPROVAL, COMPLETE, REFUNDED}
    State public currentState;

//what about this???

//get the renter and the landlord from the apartment ID
    modifier renterOnly(uint _apartmentId) { 
        //read landlord getRenter(_apartmentId)
        address renter = getTenant(_apartmentId);
        require(msg.sender == renter || msg.sender == arbiter); 
        _; 
        
    }
    modifier landlordOnly(uint _apartmentId) { 
        //read landlord getLandlord(_apartmentId)
        address landlord= getLandlord(_apartmentId);
        require(msg.sender == landlord || msg.sender == arbiter); 
        _; 
        
    }
    modifier inState(uint _apartmentId,State expectedState) { require(_lease[_apartmentId].status == expectedState); _; }

   // address public renter;
    //address public landlord;
    address public arbiter;
    
     struct LeaseStatus {
        uint balance;
        uint nrPayment;
        State status;
    }
    
    mapping (uint => LeaseStatus) internal _lease;//map each renter with the amount paid
   // mapping (uint => State) internal _state;//map each renter with the status of the payment
    
    
    //What should be the constructor??
    constructor() public {
        arbiter = msg.sender;
    }
    
    
    function sendPayment(uint _apartmentId) inState(_apartmentId,State.AWAITING_PAYMENT) public payable {
        //get apartment id 
        uint monthlyRent=getMonthlyAmt(_apartmentId);//from the apartment 
        require(msg.value>=monthlyRent);
        _lease[_apartmentId].balance = _lease[_apartmentId].balance.add(msg.value);
        _lease[_apartmentId].nrPayment = _lease[_apartmentId].nrPayment.add(1);
        
        _lease[_apartmentId].status = State.AWAITING_APPROVAL;
    }

    function confirmApproval(uint _apartmentId) renterOnly(_apartmentId) inState(_apartmentId,State.AWAITING_APPROVAL) public {
        //get landlord address from apartment and end of lease
         //read renter address get from apartment??
       //maybe check if above the balance is above Monthlyrent
      address landlord = getLandlord(_apartmentId);
      uint totPayments = getNumPayments(_apartmentId);
      
     //   bool LastMonth;// = isLastMonth(_apartmentId);
        
        uint payment=_lease[_apartmentId].balance;
        _lease[_apartmentId].balance=0;
        landlord.transfer(payment);
        if(totPayments <_lease[_apartmentId].nrPayment){
            _lease[_apartmentId].status = State.AWAITING_PAYMENT;
        }
        else{
            _lease[_apartmentId].status = State.COMPLETE;
        }
        
    }

    function refundRenter(uint _apartmentId) landlordOnly(_apartmentId) inState(_apartmentId,State.AWAITING_APPROVAL) public {
        //read renter address get from apartment
        address renter = getTenant(_apartmentId);
        uint payment=_lease[_apartmentId].balance;
        _lease[_apartmentId].balance=0;
        _lease[_apartmentId].nrPayment = _lease[_apartmentId].nrPayment.sub(1);
        renter.transfer(payment);
        _lease[_apartmentId].status = State.REFUNDED;
    }
}
