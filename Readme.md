### DAICO

This repo is forked from TokenMarketNet ICO repo and contain all the solidity contracts of the original repo.

Here are two main differences from tokenmarketnet ico contracts:
- first, DaicoToken should be in use. it is close to crowdsale token, but in addition includes a list of listeners of token transfer.
- second, DaicoVault contract introduced. It should be used as "multisig" for crowdsale contract.
The rest of code remains unchanged. To run the DAICO, it is recommended to use AllocatedCrowdsale contract.

### Deploy and testing

1. DaicoToken deploy. Contract parameters are name, symbol, decimals, mintable:
`function DaicoToken(string _name, string _symbol, uint _initialSupply, uint _decimals, bool _mintable)`
2. Pricing strategy deploy. The deploy process may vary depends on pricing strategy choosen. The most simple one is FlatPricing. Contract parameter is token price:
`function FlatPricing(uint _oneTokenInWei)`
3. DaicoVault deploy. Contract parameters are time to debate in minutes, majority margin, DAICO token contract address:
`function DaicoVault(uint minutesForDebate, uint marginOfVotesForMajority, FractionalERC20 daicoToken)`
4. DaicoToken listener setup. Call 'setListener' function of DaicoToken contract. Argument for the function is DaicoVault contract address:
`function setListener(address _listener)`
5. Crowdsale contract deploy. The deploy process may vary depends on pricing strategy choosen. The recommended one is AllocatedCrowdsale. Contract parameters are DaicoToken contract address, pricing strategy contract address, DaicoVault contract address (as _multisigWallet), crowdsale start datetime (Unix Timestamp), crowdsale end datetime (Unix Timestamp), minimul funding goal, token holder address:
`function AllocatedCrowdsale(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal, address _beneficiary)`
6. Finalize agent deploy. The deploy process may vary depends on finalize agent choosen. The most simple one is NullFinalizeAgent. Contract parameter is crowdsale contract address.
7. Crowdsale finalize agent setup. Call 'setFinalizeAgent' function of Crowdsale contract. Argument for the function is Finalize Agent contract address.
`function setFinalizeAgent(FinalizeAgent addr)`
8. Token distribution setup. Call 'approve' function of DaicoToken contract. Arguments for the function are Crowdsale address and amount of tokens to be sold during the crowdsale.
`function approve(address _spender, uint256 _value)`
9. DaicoToken release agent setup. Call 'setReleaseAgent' function of DaicoToken contract. Argument for the function is your ethereum address.
`function setReleaseAgent(address addr)`
10. Release token transfer. Call 'releaseTokenTransfer' function of DaicoToken contract. There are no arguments for the function.
`function releaseTokenTransfer()`
11. Make sure Crowdsale is ready to go. Call 'getState' function of Crowdsale contract. There are no arguments for the function. If current time is before crowdsale start time, the function should return '2'. If current time is after crowdsale start time, the function should return '3'.
`function getState()`
12. Test Crowdsale. If 'getState' returns '3', call 'buy' function of Crowdsale contract. There are no arguments for the function, but you should send some amount of ether with the transaction.
`function buy() public payable`
13. Test proposal creation. Call 'newProposal' function of DaicoVault contract. Arguments for the function are beneficiary address, amount of Ether (in Wei) to be sent, job description (could be external link):
`function newProposal(address beneficiary, uint weiAmount, string jobDescription)`
14. Test votion on proposal. Call 'vote' function of DaicoVault contract. Arguments for the function are proposal number (the first one is '0'), the vote itself (true or false), justification text:
`function vote(uint proposalNumber, bool supportsProposal, string justificationText)`
15. Test proposal execution. After debating time passed, call 'approveFunding' function of DaicoVault contract. Argument for the function is proposal number:
`function approveFunding(uint proposalNumber)` 
