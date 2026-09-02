     1	// SPDX-License-Identifier: MIT
     2	pragma solidity ^0.8.30;
     3	
...
   376	    function electionStarted() public view returns (bool) {
   377	        return isElectionStarted;
   378	    }
   379	}
Tool Call
Function Name:
Read
Arguments:
file_path:
/home/user/election.sol
Response
     1	// SPDX-License-Identifier: MIT
     2	pragma solidity ^0.8.30;
     3	
     4	/**
     5	 * @title Election
     6	 * @notice A simple chairman-controlled election contract.
     7	 */
     8	contract election {
     9	    error totalAmoutnShouldBezero();
    10	    error Election__notChairmanError();
    11	    error Not18yet();
    12	    error thisCandidateIsDeleted();
    13	    error youAreNotRegistered();
    14	    error votedAlready();
    15	    error ElectionAlreadyStarted();
    16	    error CandidateAlreadyExists();
    17	    error InvalidCandidate();
    18	    error EmptyName();
    19	    error PartyAlreadyExists();
    20	    error NoCandidates();
    21	    error ElectionNotStarted();
    22	
    23	    struct candidate {
    24	        address candidateAddr;
    25	        string candidateName;
    26	        uint256 totalCandidateVote;
    27	    }
    28	
    29	    struct Party {
    30	        uint256 id;
    31	        string name;
    32	        bool exists;
    33	    }
    34	
    35	    address[] public people;
    36	    bool private isElectionStarted;
    37	    address public highestVoter;
    38	    uint256 public highestVoterId;
    39	    address public chairman;
    40	
    41	    candidate[] public candidates;
    42	
    43	    // Candidate address => 1-based candidate ID.
    44	    // Zero means that the address is not an active candidate.
    45	    mapping(address => uint256) public candidateIdToAddr;
    46	
    47	    // Voter address => eligible voter.
    48	    mapping(address => bool) public is18Year;
    49	
    50	    // Kept for compatibility with the original project.
    51	    mapping(uint64 => candidate[]) public candidateInfo;
    52	
    53	    mapping(address => bool) public hasVoted;
    54	
    55	    // Candidate address => party ID.
    56	    mapping(address => uint256) public candidatePartyId;
    57	
    58	    // Candidate address => active/inactive.
    59	    mapping(address => bool) public candidateExists;
    60	
    61	    // Candidate ID => party ID.
    62	    mapping(uint256 => uint256) public candidateIdToParty;
    63	
    64	    Party[] public parties;
    65	    mapping(uint256 => bool) public partyExists;
    66	    mapping(bytes32 => bool) private partyNameExists;
    67	
    68	    uint256 public totalVotes;
    69	
    70	    event CandidateCreated(uint256 indexed candidateId, address indexed candidateAddress, string name);
    71	    event CandidateRemoved(uint256 indexed candidateId, address indexed candidateAddress);
    72	    event PartyCreated(uint256 indexed partyId, string name);
    73	    event VoterRegistered(address indexed voter, uint256 age);
    74	    event ElectionStarted();
    75	    event VoteCast(address indexed voter, uint256 indexed candidateId);
    76	
    77	    modifier onlyChairman() {
    78	        if (msg.sender != chairman) {
    79	            revert Election__notChairmanError();
    80	        }
    81	        _;
    82	    }
    83	
    84	    modifier electionStarted() {
    85	        if (!isElectionStarted) {
    86	            revert ElectionNotStarted();
    87	        }
    88	        _;
    89	    }
    90	
    91	    constructor() {
    92	        chairman = msg.sender;
    93	    }
    94	
    95	    function createCandidates(
    96	        address _candidateAddress,
    97	        string memory _name
    98	    ) public onlyChairman {
    99	        if (_candidateAddress == address(0)) revert InvalidCandidate();
   100	        if (bytes(_name).length == 0) revert EmptyName();
   101	        if (candidateExists[_candidateAddress]) revert CandidateAlreadyExists();
   102	        if (isElectionStarted) revert ElectionAlreadyStarted();
   103	
   104	        candidates.push(
   105	            candidate({
   106	                candidateAddr: _candidateAddress,
   107	                candidateName: _name,
   108	                totalCandidateVote: 0
   109	            })
   110	        );
   111	
   112	        uint256 id = candidates.length;
   113	        candidateIdToAddr[_candidateAddress] = id;
   114	        candidateExists[_candidateAddress] = true;
   115	
   116	        emit CandidateCreated(id, _candidateAddress, _name);
   117	    }
   118	
   119	    function getElectionStarted() public onlyChairman {
   120	        if (isElectionStarted) revert ElectionAlreadyStarted();
   121	        if (candidates.length == 0) revert NoCandidates();
   122	
   123	        isElectionStarted = true;
   124	        emit ElectionStarted();
   125	    }
   126	
   127	    /**
   128	     * Backward-compatible no-argument version.
   129	     * Creates the default Independent party if no party exists yet.
   130	     */
   131	    function createParties() public onlyChairman {
   132	        if (parties.length == 0) {
   133	            _createParty("Independent");
   134	        } else {
   135	            revert PartyAlreadyExists();
   136	        }
   137	    }
   138	
   139	    function createParties(string memory _partyName)
   140	        public
   141	        onlyChairman
   142	    {
   143	        _createParty(_partyName);
   144	    }
   145	
   146	    function createParty(string memory _partyName)
   147	        public
   148	        onlyChairman
   149	        returns (uint256)
   150	    {
   151	        return _createParty(_partyName);
   152	    }
   153	
   154	    function _createParty(string memory _partyName)
   155	        internal
   156	        returns (uint256)
   157	    {
   158	        if (bytes(_partyName).length == 0) revert EmptyName();
   159	
   160	        bytes32 nameHash = keccak256(bytes(_partyName));
   161	        if (partyNameExists[nameHash]) revert PartyAlreadyExists();
   162	
   163	        parties.push(
   164	            Party({
   165	                id: parties.length + 1,
   166	                name: _partyName,
   167	                exists: true
   168	            })
   169	        );
   170	
   171	        uint256 partyId = parties.length;
   172	        partyExists[partyId] = true;
   173	        partyNameExists[nameHash] = true;
   174	
   175	        emit PartyCreated(partyId, _partyName);
   176	        return partyId;
   177	    }
   178	
   179	    function assignCandidateToParty(
   180	        address _candidateAddress,
   181	        uint256 _partyId
   182	    ) public onlyChairman {
   183	        uint256 candidateId = candidateIdToAddr[_candidateAddress];
   184	
   185	        if (candidateId == 0 || !candidateExists[_candidateAddress]) {
   186	            revert InvalidCandidate();
   187	        }
   188	        if (!partyExists[_partyId]) revert InvalidCandidate();
   189	
   190	        candidatePartyId[_candidateAddress] = _partyId;
   191	        candidateIdToParty[candidateId] = _partyId;
   192	    }
   193	
   194	    function removeCandidate(address _candidateAddress)
   195	        public
   196	        onlyChairman
   197	    {
   198	        uint256 candidateId = candidateIdToAddr[_candidateAddress];
   199	
   200	        if (candidateId == 0 || !candidateExists[_candidateAddress]) {
   201	            revert InvalidCandidate();
   202	        }
   203	        if (isElectionStarted) revert ElectionAlreadyStarted();
   204	
   205	        candidateExists[_candidateAddress] = false;
   206	        candidateIdToAddr[_candidateAddress] = 0;
   207	
   208	        emit CandidateRemoved(candidateId, _candidateAddress);
   209	    }
   210	
   211	    /**
   212	     * Backward-compatible version of the original removeCandidates().
   213	     * Because the original function had no candidate argument, it removes
   214	     * the last active candidate.
   215	     */
   216	    function removeCandidates() public onlyChairman {
   217	        if (candidates.length == 0) revert NoCandidates();
   218	        if (isElectionStarted) revert ElectionAlreadyStarted();
   219	
   220	        for (uint256 i = candidates.length; i > 0; i--) {
   221	            address candidateAddress = candidates[i - 1].candidateAddr;
   222	
   223	            if (candidateExists[candidateAddress]) {
   224	                uint256 candidateId = candidateIdToAddr[candidateAddress];
   225	                candidateExists[candidateAddress] = false;
   226	                candidateIdToAddr[candidateAddress] = 0;
   227	
   228	                emit CandidateRemoved(candidateId, candidateAddress);
   229	                return;
   230	            }
   231	        }
   232	
   233	        revert InvalidCandidate();
   234	    }
   235	
   236	    /**
   237	     * Only the chairman can register voters.
   238	     */
   239	    function registerVoters(uint16 age, address voter)
   240	        public
   241	        onlyChairman
   242	        returns (bool)
   243	    {
   244	        if (voter == address(0)) revert InvalidCandidate();
   245	        if (age < 18) revert Not18yet();
   246	
   247	        is18Year[voter] = true;
   248	
   249	        bool alreadyRegistered = false;
   250	        for (uint256 i = 0; i < people.length; i++) {
   251	            if (people[i] == voter) {
   252	                alreadyRegistered = true;
   253	                break;
   254	            }
   255	        }
   256	
   257	        if (!alreadyRegistered) {
   258	            people.push(voter);
   259	        }
   260	
   261	        emit VoterRegistered(voter, age);
   262	        return true;
   263	    }
   264	
   265	    /**
   266	     * Cast one vote.
   267	     * The voter is always msg.sender; the voterAddress argument is retained
   268	     * only for compatibility with the original function signature.
   269	     */
   270	    function vote(
   271	        uint64 id,
   272	        address candidateAddress,
   273	        uint16,
   274	        address voterAddress
   275	    ) public electionStarted {
   276	        uint256 candidateId = candidateIdToAddr[candidateAddress];
   277	
   278	        if (
   279	            candidateId == 0 ||
   280	            !candidateExists[candidateAddress] ||
   281	            id != candidateId
   282	        ) {
   283	            revert thisCandidateIsDeleted();
   284	        }
   285	
   286	        if (!is18Year[msg.sender] || voterAddress != msg.sender) {
   287	            revert youAreNotRegistered();
   288	        }
   289	
   290	        if (hasVoted[msg.sender]) {
   291	            revert votedAlready();
   292	        }
   293	
   294	        candidates[candidateId - 1].totalCandidateVote += 1;
   295	        hasVoted[msg.sender] = true;
   296	        totalVotes += 1;
   297	
   298	        winner(uint64(candidateId));
   299	
   300	        emit VoteCast(msg.sender, candidateId);
   301	    }
   302	
   303	    /**
   304	     * Update the current leader.
   305	     */
   306	    function winner(uint64 id) private {
   307	        if (id == 0 || id > candidates.length) {
   308	            revert InvalidCandidate();
   309	        }
   310	
   311	        if (highestVoterId == 0) {
   312	            highestVoterId = id;
   313	            highestVoter = candidates[id - 1].candidateAddr;
   314	            return;
   315	        }
   316	
   317	        if (
   318	            candidates[id - 1].totalCandidateVote >
   319	            candidates[highestVoterId - 1].totalCandidateVote
   320	        ) {
   321	            highestVoterId = id;
   322	            highestVoter = candidates[id - 1].candidateAddr;
   323	        }
   324	    }
   325	
   326	    /**
   327	     * Return the winning candidate's 1-based ID.
   328	     * Returns 0 when nobody has received a vote.
   329	     */
   330	    function getWinner() public view returns (uint256) {
   331	        if (candidates.length == 0) return 0;
   332	
   333	        uint256 winningId = 0;
   334	        uint256 winningVotes = 0;
   335	
   336	        for (uint256 i = 0; i < candidates.length; i++) {
   337	            address candidateAddress = candidates[i].candidateAddr;
   338	
   339	            if (!candidateExists[candidateAddress]) continue;
   340	
   341	            if (candidates[i].totalCandidateVote > winningVotes) {
   342	                winningVotes = candidates[i].totalCandidateVote;
   343	                winningId = i + 1;
   344	            }
   345	        }
   346	
   347	        return winningId;
   348	    }
   349	
   350	    function getWinnerAddress() public view returns (address) {
   351	        uint256 winnerId = getWinner();
   352	        if (winnerId == 0) return address(0);
   353	        return candidates[winnerId - 1].candidateAddr;
   354	    }
   355	
   356	    function getCandidateVoteCount(uint256 candidateId)
   357	        public
   358	        view
   359	        returns (uint256)
   360	    {
   361	        if (candidateId == 0 || candidateId > candidates.length) {
   362	            revert InvalidCandidate();
   363	        }
   364	
   365	        return candidates[candidateId - 1].totalCandidateVote;
   366	    }
   367	
   368	    function getCandidatesCount() public view returns (uint256) {
   369	        return candidates.length;
   370	    }
   371	
   372	    function getPartiesCount() public view returns (uint256) {
   373	        return parties.length;
   374	    }
   375	
   376	    function electionStarted() public view returns (bool) {
   377	        return isElectionStarted;
   378	    }
   379	}