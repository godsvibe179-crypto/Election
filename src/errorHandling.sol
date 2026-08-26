//SPDX-Lincense-Identifier: MIT
pragma solidity ^0.8.30;


contract errorHandling {
    // is the process of handling, managing different checks, error declaration in solidity 

    // there are 2 differnt types of error handling.
    // require statement and the if/revert
    // i want only the election chaiman to be able to create a candidate
    error totalAmoutnShouldBezero();
    // actor cfor chairman
    address chairman = 0x545DF19a98CD6E243AbBc7C41Ae5b940F0325223;
    uint256 maxAmountOfVotes = 34;
    function createCandidates() public view {
        uint256 totalAmountOfCandidate = 0;
        // i want to set an instruction, if the chairman is not the person calling the create
        // candidate function throw an error and the tx should not ne executed
        // 0x545DF19a98CD6E243AbBc7C41Ae5b940F0325223 == 0x545DF19a98CD6E243AbBc7C41Ae5b940F0325223
        // == for comparing that 2 times are equal
        // != or comparing that 2 times are NOT equal
        require(chairman == msg.sender, "you are a fool, you are not the chaiman"); 

        // 2nd method to declare error handling
        if (totalAmountOfCandidate != 0) {
            revert totalAmoutnShouldBezero();
        }
    }
// check: 
}