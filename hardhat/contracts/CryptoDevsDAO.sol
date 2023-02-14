// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IFakeNFTMarketplace {
    function purchase(uint256 _tokenId) external payable;
    function getPrice() external view returns (uint256);
    function available(uint256 _tokenId) external view returns(bool);
}

interface ICryptoDevsNFT {
    function balanceOf(address owner) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}

contract CryptoDevsDAO is Ownable {
    // store created proposal in contract state
    //allow holders of cryptodev NFT to create a proposal
    //allow holders of cryptodev NFT to vote on the proposal as long as the deadline is not passed
    //execute proposal after the proposal deadline is over - i.e. buy an NFT

    //defining struct for the proposal
    struct Proposal{
       //once the proposal is passed, this token Id will be used to purchase NFT from the fake NFT marketplace that is created.
       uint256 nftTokenId;
       uint256 deadline;
       mapping (uint256 => bool) voters; //whether the voter voted or not
       bool executed; //whether the proposal is executed;
       uint256 yayVotes;
       uint256 nayVotes;
    }

    mapping(uint256 => Proposal) public proposals;
    
    uint256 numProposals;

    IFakeNFTMarketplace nftMarketplace;
    ICryptoDevsNFT cryptoDevsNFT;

    constructor(address _nftMarketplace, address _cryptodevsNFT) payable{
       nftMarketplace = IFakeNFTMarketplace(_nftMarketplace);
       cryptoDevsNFT = ICryptoDevsNFT(_cryptodevsNFT);
    }

    modifier nftHoldersOnly {
        require(cryptoDevsNFT.balanceOf(msg.sender) > 0);
        _;
    }

    modifier activeProposalOnly(uint256 proposalIndex) {
    require(
        proposals[proposalIndex].deadline > block.timestamp,
        "DEADLINE_EXCEEDED"
    );
    _;
}

    enum Vote {
    YAY, 
    NAY 
    }

    //create proposal function 
    function createProposal(uint256 _nftTokenId) external nftHoldersOnly returns (uint256){
        require(nftMarketplace.available(_nftTokenId), "This tokenId NFT is not available");
        Proposal storage proposal = proposals[numProposals];
        proposal.nftTokenId = _nftTokenId;
        proposal.deadline = block.timestamp + 5 minutes;

        numProposals++;
        return numProposals - 1;
    }

    function voteOnProposal(uint256 proposalIndex, Vote vote) external nftHoldersOnly activeProposalOnly(proposalIndex){
        Proposal storage proposal = proposals[proposalIndex];

        uint256 voterNFTBalance = cryptoDevsNFT.balanceOf(msg.sender);
        uint numVotes = 0;

        for (uint256 i = 0; i < voterNFTBalance; i++){

            uint256 tokenId = cryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
            if(proposal.voters[tokenId] == false){
                numVotes++;
                proposal.voters[tokenId] = true;
            }
        }
        require(numVotes > 0, "Already voted");

    if(vote == Vote.YAY){
        proposal.yayVotes += numVotes;
    }else{
        proposal.nayVotes += numVotes;
    }
    }

    //modifier to execute the proposal
    modifier inActiveProposal(uint256 _proposalIndex) {
        require(proposals[_proposalIndex].deadline <= block.timestamp, "deadline not exceeded");
        require(proposals[_proposalIndex].executed == false, "Proposal already executed");
        _;
    }
    
    function executeProposal(uint256 proposalIndex) external nftHoldersOnly inActiveProposal(proposalIndex){
        Proposal storage proposal = proposals[proposalIndex];
        if (proposal.yayVotes > proposal.nayVotes) {
        uint256 nftPrice = nftMarketplace.getPrice();
        require(address(this).balance >= nftPrice, "not enough funds");
        nftMarketplace.purchase{value: nftPrice}(proposal.nftTokenId);
    }

    proposal.executed = true;
    }

    function withdraw() external onlyOwner{
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw");
        payable(owner()).transfer(amount);
    }

    receive() external payable {}

    fallback() external payable {}

}