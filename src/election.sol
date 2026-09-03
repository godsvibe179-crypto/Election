// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract election {
    error Election__NotChairman();
    error Election__AlreadyStarted();
    error Election__NotStarted();
    error Election__NoCandidates();
    error Election__InvalidCandidate();
    error Election__CandidateExists();
    error Election__CandidateDeleted();
    error Election__InvalidVoter();
    error Election__NotRegistered();
    error Election__AlreadyVoted();
    error Election__PartiesAlreadyCreated();

    struct candidate {
        address candidateAddr;
        string candidateName;
        uint256 totalCandidateVote;
    }

    struct party {
        address candidateAddr;
        string partyName;
    }

    address[] public people;
    bool private isElectionStarted;
    bool private partiesCreated;

    // One-based candidate ID. Zero means no votes have been recorded.
    uint256 private highestVoterId;

    address public chairman;
    candidate[] public candidates;
    party[] public parties;

    // Candidate IDs are one-based.
    // Zero means that the address is not an active candidate.
    mapping(address => uint256) public candidateIdToAddr;

    mapping(address => bool) public is18Year;
    mapping(uint64 => candidate[]) public candidateInfo;
    mapping(address => bool) public hasVoted;

    constructor() {
        chairman = msg.sender;
    }

    modifier onlyChairman() {
        if (msg.sender != chairman) revert Election__NotChairman();
        _;
    }

    function createCandidates(
        address _candidateAddress,
        string memory _name
    ) public onlyChairman {
        if (isElectionStarted) {
            revert Election__AlreadyStarted();
        }

        if (_candidateAddress == address(0)) {
            revert Election__InvalidCandidate();
        }

        if (candidateIdToAddr[_candidateAddress] != 0) {
            revert Election__CandidateExists();
        }

        candidates.push(
            candidate({
                candidateAddr: _candidateAddress,
                candidateName: _name,
                totalCandidateVote: 0
            })
        );

        candidateIdToAddr[_candidateAddress] = candidates.length;
    }

    function getElectionStarted() public onlyChairman {
        if (candidates.length == 0) {
            revert Election__NoCandidates();
        }

        isElectionStarted = true;
    }

    /*
     * The original function has no parameters for party names.
     * Therefore, each candidate's name is used as the party name.
     */
    function createParties() public onlyChairman {
        if (isElectionStarted) {
            revert Election__AlreadyStarted();
        }

        if (partiesCreated) {
            revert Election__PartiesAlreadyCreated();
        }

        if (candidates.length == 0) {
            revert Election__NoCandidates();
        }

        for (uint256 i = 0; i < candidates.length; ++i) {
            parties.push(
                party({
                    candidateAddr: candidates[i].candidateAddr,
                    partyName: candidates[i].candidateName
                })
            );
        }

        partiesCreated = true;
    }

    /*
     * Backwards-compatible no-argument removal:
     * removes the last candidate.
     */
    function removeCandidates() public onlyChairman {
        if (candidates.length == 0) {
            revert Election__NoCandidates();
        }

        _removeCandidate(candidates[candidates.length - 1].candidateAddr);
    }

    function removeCandidates(address candidateAddress) public onlyChairman {
        _removeCandidate(candidateAddress);
    }

    function _removeCandidate(address candidateAddress) internal {
        uint256 id = candidateIdToAddr[candidateAddress];

        if (id == 0) {
            revert Election__CandidateDeleted();
        }

        delete candidateIdToAddr[candidateAddress];
    }

    function vote(
        uint64 id,
        address candidateAddress,
        uint16 age,
        address voterAddress
    ) public {
        if (!isElectionStarted) {
            revert Election__NotStarted();
        }

        if (voterAddress != msg.sender || age < 18) {
            revert Election__InvalidVoter();
        }

        if (hasVoted[msg.sender]) {
            revert Election__AlreadyVoted();
        }

        if (id == 0 || id > candidates.length) {
            revert Election__InvalidCandidate();
        }

        if (candidateIdToAddr[candidateAddress] != id) {
            revert Election__CandidateDeleted();
        }

        is18Year[msg.sender] = true;

        candidates[id - 1].totalCandidateVote += 1;
        hasVoted[msg.sender] = true;
        people.push(msg.sender);

        _updateWinner(id);
    }

    function _updateWinner(uint256 id) internal {
        if (
            highestVoterId == 0
                || candidates[id - 1].totalCandidateVote
                    > candidates[highestVoterId - 1].totalCandidateVote
        ) {
            highestVoterId = id;
        }
    }

    /*
     * Chairman-only voter registration helper.
     * Voters are also validated automatically when they call vote().
     */
    function registerVoters(
        uint16 age,
        address voter
    ) public onlyChairman returns (bool) {
        if (age < 18 || voter == address(0)) {
            revert Election__InvalidVoter();
        }

        is18Year[voter] = true;
        return true;
    }

    /*
     * Returns the winning candidate's one-based ID.
     * Returns zero if no votes have been cast.
     */
    function getWinner() public view returns (uint256) {
        return highestVoterId;
    }

    function electionStarted() external view returns (bool) {
        return isElectionStarted;
    }
}