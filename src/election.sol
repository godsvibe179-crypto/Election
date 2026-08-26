// SPDX-Lincense-Identifier: MIT
pragma solidity ^0.8.30;

contract election {
    // 1. we want difereent candiditate to be able to vote
// 2. elections to be able to be called/ started.
// 3. we want different paties
// 4. we want to be able to remove candidates
// 5. we will be able to vote
// 6. determine the winner
    error totalAmoutnShouldBezero();
    error Election__notChairmanError();
    error Not18yet();
    error thisCandidateIsDeleted();
    error youAreNotRegistered();
    error votedAlready();
    struct candidate {
        address candidateAddr;
        string candidateName;
        uint256 totalCandidateVote;
    }
    address[] public people;
    bool private isElectionStarted = false;
    address highestVoter;
    uint256 highestVoterId;

    address public chairman;
    // <array type keyword> visibility <array name>
    candidate[] public candidates;
    // first person 
    //  address candidateAddr;
    //     string candidateName;
    //     uint256 totalcandidate[]CandidateVote;

    // 2nd person 
    //  address candidateAddr;
    //     string candidateName;
    //     uint256 totalCandidateVote;

    //      3rd  person
    //       candidateAddr;
    //     string candidateName;
    //     uint256 totalCandidateVote;

    mapping (address  => uint256 id) public candidateIdToAddr;
        //   address1         | 1
        //   address2        |  2
        //   address3        |  0
                  
    mapping (address => bool) public is18Year;
    mapping (uint64 => candidate[]) public candidateInfo;
    mapping (address => bool) public hasVoted;

// only the inec chariman
    function createCandidates(address _candidateAddress, string memory _name) public {

        uint256 totalAmountOfCandidate = 0;
        uint256 id = 1;
        candidateIdToAddr[msg.sender] = id;
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
        // owner 
        // if (msg.sender == )
        candidates.push(candidate({
            candidateAddr: _candidateAddress, 
            candidateName: _name,
            totalCandidateVote: totalAmountOfCandidate
        }));
    }
    // done 
    function getElectionStarted() public {
        // callable by the chairman alone
            // if i want enforce that the chairman can press this function, a particular variable should turn to true.
        if (msg.sender != chairman) {
            revert Election__notChairmanError();
        }
        isElectionStarted = true;
        

    }
    // TO-do complete this function
    function createParties() public {

    }
    // remove candidate function
    function removeCandidates() public {
        if (msg.sender != chairman) {
            revert Election__notChairmanError();
        }
        
        delete candidateIdToAddr[msg.sender];

    }
    // 
    function vote(uint64 id, address candidateAddress, uint16 age, address voterAddress) public {
        require(isElectionStarted == true, "wait for your chairman, getelection started function is not called yet");
        //1. if a candidate is deleted, make sure that he cant be voted for
        if (candidateIdToAddr[candidateAddress] == 0) {
            revert thisCandidateIsDeleted();
        }
        //2. are you registered by the chairma
        if (registerVoters(age, voterAddress) == false) {
            revert youAreNotRegistered();
        }
        //3. people cant vote 2 times
            // use a mapping the check that an address has voted or not
        if (hasVoted[msg.sender] == true) {
            revert votedAlready();
        }
        // for each person that calls the vote function, the candidate he want to vote for should increase by 1
        // <array name>[index]; 
        // x = 5
        //x = x + 1
        // 6
        candidates[id-1].totalCandidateVote = candidates[id-1].totalCandidateVote + 1;
        
        hasVoted[msg.sender] = true;

        winner(id);
    }
    function winner(uint64 id) private {
        // if that current candidate that a voter votes for, we will that the current voted person for is more that the higtest candadite at that moment
        // samuel 
        
        if (candidates[id].totalCandidateVote > candidates[highestVoterId].totalCandidateVote) {
            highestVoterId = id;
        }
        
    }

    function registerVoters(uint16 age, address voter) public returns(bool) {
        if (voter != chairman) {
            revert Election__notChairmanError();
        }
        if (age < 18) {
            revert Not18yet();
        }
        is18Year[voter] = true;

        return true;
    }

    ///////////GETTER FUNCTION////////
    // complete this function 
    function getWinner() public view returns(uint256) {
        // winner();
    }
}