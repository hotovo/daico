
pragma solidity ^0.4.18;

import "./SafeMathLib.sol";
import "./FractionalERC20.sol";

contract DaicoVault is ITokenEventListener {
  using SafeMathLib for uint;

  // The token investors are holding
  FractionalERC20 public token;

  uint public debatingPeriodInMinutes;
  uint public majorityMargin;
  Proposal[] public proposals;
  uint public numProposals;

  event ProposalAdded(uint proposalID, address recipient, uint amount, string description);
  event Voted(uint proposalID, bool position, address voter, string justification);
  event ProposalTallied(uint proposalID, uint positiveResult, uint negativeResult, bool active);

  struct Vote {
    bool inSupport;
    address voter;
    string justification;
  }

  struct Proposal {
    address recipient;
    uint amount;
    string description;
    uint votingDeadline;
    bool executed;
    bool proposalPassed;
    uint numberOfVotes;
    uint currentResult;
    uint positiveResult;
    uint negativeResult;
    mapping (address => bool) supported;
    mapping (address => uint) voted;
  }

  // Modifier that allows only shareholders to vote and create new proposals
  modifier onlyMembers {
    require(token.balanceOf(msg.sender) != 0);
    _;
  }

  modifier noOngoingProposals {
    require ((numProposals == 0) || (proposals[numProposals - 1].executed));
    _;
  }

  function DaicoVault(uint minutesForDebate, uint marginOfVotesForMajority,
    FractionalERC20 daicoToken) public {
    debatingPeriodInMinutes = minutesForDebate;
    majorityMargin = marginOfVotesForMajority;
    token = daicoToken;
  }

  function () public payable {
  }

  /**
    * Add Proposal
    *
    * Propose to send `weiAmount / 1e18` ether to `beneficiary` for `jobDescription`. `transactionBytecode ? Contains : Does not contain` code.
    *
    * @param beneficiary who to send the ether to
    * @param weiAmount amount of ether to send, in wei
    * @param jobDescription Description of job
    */
  function newProposal(address beneficiary, uint weiAmount, string jobDescription)
  onlyMembers noOngoingProposals public returns (uint proposalID) {

    proposalID = proposals.length++;
    Proposal storage p = proposals[proposalID];
    p.recipient = beneficiary;
    p.amount = weiAmount;
    p.description = jobDescription;
    p.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
    p.executed = false;
    p.proposalPassed = false;
    ProposalAdded(proposalID, beneficiary, weiAmount, jobDescription);
    numProposals = proposalID+1;

    return proposalID;
  }

  /**
    * Log a vote for a proposal
    *
    * Vote `supportsProposal? in support of : against` proposal #`proposalNumber`
    *
    * @param proposalNumber number of proposal
    * @param supportsProposal either in favor or against it
    * @param justificationText optional justification text
    */
  function vote(uint proposalNumber, bool supportsProposal, string justificationText)
  onlyMembers public {
    require (p.voted[msg.sender] == 0);
    Proposal storage p = proposals[proposalNumber];         // Get the proposal
    p.voted[msg.sender] = token.balanceOf(msg.sender);      // Set this voter as having voted
    if (supportsProposal) {                         // If they support the proposal
      p.positiveResult = p.positiveResult.plus(p.voted[msg.sender]);  // Increase score
      p.supported[msg.sender] = true;
    } else {                                        // If they don't
      p.negativeResult = p.negativeResult.minus(p.voted[msg.sender]); // Decrease the score
      p.supported[msg.sender] = false;
    }

    // Create a log of this event
    Voted(proposalNumber, supportsProposal, msg.sender, justificationText);
  }

  /**
     * Finish vote
     *
     * Count the votes proposal #`proposalNumber` and execute it if approved
     *
     * @param proposalNumber proposal number
     */
  function approveFunding(uint proposalNumber) public {
    Proposal storage p = proposals[proposalNumber];

    require(now > p.votingDeadline                                            // If it is past the voting deadline
    && !p.executed);                                  // and a minimum quorum has been reached...

    // ...then execute result

    uint result = p.positiveResult.minus(p.negativeResult);
    if (result > majorityMargin) {
      // Proposal passed; execute the transaction

      p.executed = true; // Avoid recursive calling
      require(p.recipient.call.value(p.amount)());

      p.proposalPassed = true;
    } else {
      // Proposal failed
      p.proposalPassed = false;
    }

    // Fire Events
    ProposalTallied(proposalNumber, p.positiveResult, p.negativeResult, p.proposalPassed);
  }

  function onTokenTransfer(address _from, address _to, uint256 _value) public {
    require (msg.sender() == token);
    if (numProposals == 0) {
      return;
    }
    Proposal currentProposal = proposals[numProposals - 1];
    if ((currentProposal.executed) || (token.balanceOf(_from) > p.voted[_from])) {
        return;
    }
    currentProposal.voted[_from] = token.balanceOf(_from);
    if (currentProposal.voted[_to] != 0) {
      currentProposal.voted[_to] = token.balanceOf(_to);
    }

  }

}