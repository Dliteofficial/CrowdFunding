/*
Smart-Contract created by Dliteofficial
Date Created: 12 July 2022
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract CrowdFunding {
    //events
    event campaignStarted (address _recipient, uint _targetAmount, uint _amountRaised);
    event donationMade (address donor, uint _amount);
    event withdrawalMade (address _recipient, uint _amount);

    //struct to capture each campaign information
    struct Campaign {
        address payable recipient;
        uint targetAmount;
        uint amountRaised;
        Donors [] donorsList;
    }

    //struct to keep track of each donors information
    struct Donors {
        address donor;
        uint amount;
    }

    //mapping to access campaign elements
    mapping (uint => Campaign) campaigns;

    uint campaignId = 0; //campaign ID

    //modifier to ensure that only the recipient of the funds of a contract can fire a function
    modifier isRecipient (uint _campaignId) {
         require (campaigns[_campaignId].recipient == msg.sender);
        _;
    }

    //function to begin a campaign
    //function initializes elements of the campaign
    function startCampaign (address payable _recipient, uint _targetAmount) public {
        campaigns[campaignId].recipient = _recipient;
        campaigns[campaignId].targetAmount = _targetAmount;
        campaigns[campaignId].amountRaised = 0;
        campaignId++;
        emit campaignStarted(_recipient, _targetAmount, 0); 
    }

    //function that allows a donor to donate to a cause
    //stores information about a donor
    //emits information regarding the state of the transaction
    function donate (uint _campaignId, uint _amount) public payable {
        require (campaigns[_campaignId].amountRaised < campaigns[_campaignId].targetAmount);
        campaigns[_campaignId].amountRaised += _amount;
        campaigns[_campaignId].donorsList.push(Donors(msg.sender, _amount));
        emit donationMade(msg.sender, _amount);
    }

    //function provides you with the list of donors and amount donated for the campaign
    //had to improvise since mappings do not have the length function/object
    //created an array, stored mapping information in and printed it out
    function getDonors (uint _campaignId) public view returns (address [] memory, uint [] memory) {
        address [] memory addr = new address [] (campaigns[_campaignId].donorsList.length);
        uint [] memory _amount = new uint [] (campaigns[_campaignId].donorsList.length);

        for (uint i; i < campaigns[_campaignId].donorsList.length; i++){
            addr[i] = campaigns[_campaignId].donorsList[i].donor;
            _amount[i] = campaigns[_campaignId].donorsList[i].amount;
        }

        return (addr, _amount);
    }

        //function to view all campaigns to decide which to support
        function getCampaigns () public view returns (uint [] memory, uint [] memory) {

        uint [] memory cIndex = new uint [] (campaignId);
        uint [] memory cIndexAmount = new uint [] (campaignId);

        for (uint i = 0; i < campaignId; i++){
            cIndex[i] = i;
            cIndexAmount[i] = campaigns[i].targetAmount;
        }
        return (cIndex, cIndexAmount);
    }

    //checks if a campaign is completed, takes a campaign ID as input
    function isCompleted (uint _campaignId) public view returns (bool success) {
        if (campaigns[_campaignId].targetAmount == campaigns[_campaignId].amountRaised){

            success = true;
        }
    }

    //function to withdraw, only the recipient of the campaign can fire this function
    function withdraw (uint _campaignId) public isRecipient (_campaignId){
        require(address(this).balance != 0);
        campaigns[_campaignId].recipient.transfer (address(this).balance);
        campaigns[_campaignId].amountRaised -= address(this).balance;
        emit withdrawalMade(campaigns[_campaignId].recipient, address(this).balance);
    }
}