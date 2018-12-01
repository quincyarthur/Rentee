pragma solidity ^0.4.0 ;

contract CryptoRent {

    struct Landlord{
        string fname;
        string lname;
    }
    
    struct Apartment {
        address landlord;
        uint num_rooms;
        uint num_bathrooms;
        uint num_square_feet;
        uint amount;
        string url;
        string location;
        uint deposit;
        bool rented;
    }
    
    struct Lease {
        uint start_date;
        uint end_date;
        uint num_payments;
        address tenant;
    }
    
    uint uid;
    mapping(uint => Apartment) apartments;
    mapping(address => mapping(uint => Apartment)) landlords;
    mapping(uint => Lease) leases;
    mapping (address => uint) renters;
    
    //Events
    //Create Apartment
    event ApartmentCreated(uint apartment_id);
    //Sign Lease
    event SignedLease(uint apartment_id, address tenant);
    //Release Lease
    event ReleaseLease(uint apartment_id, address tenant);
    
    constructor (){
        uid = 0;
    }
    
    function createApartment(uint _num_rooms,uint _num_bathrooms,uint _sq_ft, uint _mthly_amt,string _url, string _location,uint _deposit) {
        Apartment storage apartment;
        apartment.landlord = msg.sender;
        apartment.num_rooms =  _num_rooms;
        apartment.num_bathrooms = _num_bathrooms;
        apartment.num_square_feet = _sq_ft;
        apartment.amount = _mthly_amt;
        apartment.url = _url;
        apartment.location = _location;
        apartment.deposit = _deposit;
        apartment.rented = false;
        
        landlords[msg.sender][uid] = apartment;
        apartments[uid] = apartment;
        emit ApartmentCreated(uid);
        uid++;
        
    }
    
    function getLandlord(uint _apartment_id) returns (address){
        return apartments[_apartment_id].landlord;
    }
    
    function getTenant(uint _apartment_id) public returns (address){
        require(apartments[_apartment_id].rented, "This apartment has not yet been rented");
        return leases[_apartment_id].tenant;
    }
    
    function getNumRooms(uint _apartment_id) returns (uint){
        return apartments[_apartment_id].num_rooms;
    }
    
    function getNumBathrooms(uint _apartment_id) returns (uint){
        return apartments[_apartment_id].num_bathrooms;
    }
    
    function getNumSqFt(uint _apartment_id) returns (uint){
        return apartments[_apartment_id].num_square_feet;
    }
    
    function getDeposit(uint _apartment_id) returns (uint){
        return apartments[_apartment_id].deposit;
    }
    
    function getLocation(uint _apartment_id) returns (string){
        return apartments[_apartment_id].location;
    }
    
    function getURL(uint _apartment_id) returns (string){
        return apartments[_apartment_id].url;
    }
    
    function isRented(uint _apartment_id) returns (bool){
        return apartments[_apartment_id].rented;
    }
    
    function getMonthlyAmt(uint _apartment_id) returns (uint){
        return apartments[_apartment_id].amount;
    }
    
    function getNumPayments(uint _apartment_id) returns (uint) {
        return leases[_apartment_id].num_payments;
    }
    
    function getTenantsApartment(address _tenant) returns (uint){
        return renters[_tenant];
    }
    
    function signLease(address _tenant, uint _apartment_id,uint _start_date, uint _end_date, uint _num_payments) public {
        //ensure tenant has enough to pay deposit
        require(_tenant.balance >= apartments[_apartment_id].deposit, "Insuffient Funds Cannot Sign Lease");
        //ensure property isn't already rented
        require(!apartments[_apartment_id].rented, "Apartment is already rented");
        
        Lease storage lease;
        lease.start_date = _start_date;
        lease.end_date = _end_date;
        lease.num_payments = _num_payments;
        lease.tenant = msg.sender;
        
        leases[_apartment_id] = lease;
        apartments[_apartment_id].rented = true;
        renters[msg.sender] = _apartment_id;
        
        emit SignedLease(_apartment_id, msg.sender);
    }
    
    function expireLease(uint _apartment_id){
        apartments[_apartment_id].rented = false;
        emit ReleaseLease(_apartment_id, leases[_apartment_id].tenant);
    }
}
