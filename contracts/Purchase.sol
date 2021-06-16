// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
//pragma experimental ABIEncoderV2;

contract Purchase {
    enum enqStatus {created, ended, received, paid}
    struct Bid {
        uint256 amount;
        string supName;
        address payable bidder;
    }

    struct Enquery {
        uint256 enqno;
        uint256 enqEndTime;
        string partNo;
        string partName;
        string uom;
        uint256 qty;
        string buyerName;
        string locationAddress;
        enqStatus status;
        Bid lowestBid;
        address payable buyerAdd;
        uint256 buyerDeposit;
        uint256 sellerRcvDeposit;
        uint256 sellerPaidDeposit;
    }

    Enquery[] enqueries;

    event EnqueryCreated(
        uint256 enqno,
        uint256 duration,
        string partNo,
        string partName,
        uint256 qty,
        string buyerName
    );   

    function createEnquery(
        uint256 enqno,
        uint256 duration,
        string memory partNo,
        string memory partName,
        string memory uom,
        uint256 qty,
        string memory buyerName,
        string memory locationAddress,
        uint256 buyerDeposit,
        uint256 sellerRcvDeposit,
        uint256 sellerPaidDeposit
    ) public payable returns (uint256) {
        require(
            msg.value == buyerDeposit,
            "buyer deposite is not as much as mentioned"
        );
        Enquery memory enquery;
        uint256 id = enqueries.length;
        enquery.enqno = enqno;
        enquery.enqEndTime = block.timestamp + duration;
        enquery.partNo = partNo;
        enquery.partName = partName;
        enquery.uom = uom;
        enquery.qty = qty;
        enquery.buyerName = buyerName;
        enquery.locationAddress = locationAddress;
        enquery.lowestBid.amount = 0;
        enquery.buyerAdd = msg.sender;
        enquery.buyerDeposit = buyerDeposit;
        enquery.sellerRcvDeposit = sellerRcvDeposit;
        enquery.sellerPaidDeposit = sellerPaidDeposit;
        enqueries.push(enquery);
        emit EnqueryCreated(enqno, duration, partNo, partName, qty, buyerName);
        return id;
    }

    //  modifier notBuyer(uint _enqid) {
    //       require(msg.sender != enqueries[_enqid].buyerAdd, "Buyer not allow to bid");
    //       _;
    //   }

    function placeBid(
        uint256 _enqid,
        uint256 _enqno,
        uint256 _amount,
        string memory _supName
    ) public payable returns (bool) {
        //notBuyer(_enqid) returns (bool) {
        uint256 refundVal;
        require(_enqid < enqueries.length, "not a valid enquery");
        require(
            msg.sender != enqueries[_enqid].buyerAdd,
            "Buyer not allow to bid"
        );
        require(enqueries[_enqid].enqno == _enqno, "not a valid enquery no");
        require(
            enqueries[_enqid].status == enqStatus.created,
            "enquery not open any more"
        );
        if (enqueries[_enqid].lowestBid.bidder != address(0)) {
            require(
                enqueries[_enqid].lowestBid.amount > _amount,
                "your quotation price greater than lowest offer"
            );
        }
        require(
            enqueries[_enqid].enqEndTime > block.timestamp,
            "enquery has been ended"
        );
        refundVal =
            enqueries[_enqid].sellerRcvDeposit +
            enqueries[_enqid].sellerPaidDeposit;
        require(
            msg.value == refundVal,
            "you deposit not equal the require amount"
        );
        if (enqueries[_enqid].lowestBid.bidder != address(0)) {
            enqueries[_enqid].lowestBid.bidder.transfer(refundVal); // refund back the seller that not win the enquery
        }
        enqueries[_enqid].lowestBid.amount = _amount;
        enqueries[_enqid].lowestBid.supName = _supName;
        enqueries[_enqid].lowestBid.bidder = msg.sender;
        return true;
    }

    function endEnquery(uint256 _enqid) public returns(bool) {
        require(_enqid < enqueries.length, "not a valid enquery");
        require(
            msg.sender == enqueries[_enqid].buyerAdd,
            "just buyer can close the enquery"
        );
        require(
            enqueries[_enqid].enqEndTime < block.timestamp,
            "The enquery has some times to finish"
        );
        enqueries[_enqid].status = enqStatus.ended;
        return true;
    }

    function receivedItem(uint256 _enqid) public payable  returns(bool) {
        require(_enqid < enqueries.length, "not a valid enquery");
        require(
            enqueries[_enqid].status == enqStatus.ended,
            "Enquery must be in the end state"
        );
        require(
            msg.sender == enqueries[_enqid].buyerAdd,
            "just buyer can tell that received the item"
        );
        enqueries[_enqid].status = enqStatus.received;
        enqueries[_enqid].lowestBid.bidder.transfer(
            enqueries[_enqid].sellerRcvDeposit
        ); // refund back the winner when buyer received the item
        return true;
    }

    function settlement(uint256 _enqid) public payable  returns(bool) {
        require(_enqid < enqueries.length, "not a valid enquery");
        require(
            enqueries[_enqid].status == enqStatus.received,
            "Enquery must be in received state"
        );
        require(
            msg.sender == enqueries[_enqid].lowestBid.bidder,
            "just winner can do settlement"
        );
        enqueries[_enqid].status = enqStatus.paid;
        enqueries[_enqid].lowestBid.bidder.transfer(
            enqueries[_enqid].sellerPaidDeposit
        ); // refund back the winner and buyer when settlement has been done
        enqueries[_enqid].buyerAdd.transfer(enqueries[_enqid].buyerDeposit); // refund back the winner and buyer when settlement has been done
        return true;
    }

    function getEnquery(uint256 id)
        public
        view
        returns (
            uint256,
            uint256,
            string memory,
            string memory,
            string memory,
            uint256,
            string memory,
            string memory,
            enqStatus,
            uint256
        )
    {
        Enquery memory enquery = enqueries[id];
        return (
            enquery.enqno,
            enquery.enqEndTime,
            enquery.partNo,
            enquery.partName,
            enquery.uom,
            enquery.qty,
            enquery.buyerName,
            enquery.locationAddress,
            enquery.status,
            enquery.buyerDeposit
        );
    }

    function getBid(uint256 id)
        public
        view
        returns (
            address,
            uint256,
            string memory,
            address,
            uint256,
            uint256            
        )
    {
        Enquery memory enquery = enqueries[id];
        return (
            enquery.lowestBid.bidder,
            enquery.lowestBid.amount,
            enquery.lowestBid.supName,
            enquery.buyerAdd,
            enquery.sellerRcvDeposit,
            enquery.sellerPaidDeposit            
        );
    }

    function getEnqueryCount() public view returns (uint256 count) {
        return (enqueries.length);
    }

    function getBlocktime() external view returns (uint) {
    return (block.timestamp);
    }

}
