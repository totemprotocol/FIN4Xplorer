pragma solidity ^0.5.0;

import "contracts/proof/Fin4BaseProofType.sol";

contract MaximumQuantityPerInterval is Fin4BaseProofType {

  constructor(address Fin4MainAddress)
    Fin4BaseProofType(Fin4MainAddress)
    public {
      name = "MaximumQuantityPerInterval";
      description = "Defines the maximum quantity a user can claim within a specified time interval";
      // interval = 1 * 24 * 60 * 60 * 1000; // 1 day
      // maxQuantity = 10;
      messageType = MessageType.INFO;
    }

    function submitProof(address tokenAdrToReceiveProof, uint claimId) public returns(bool) {
      if (requirementMet(tokenAdrToReceiveProof, msg.sender, claimId)) {
        _sendApproval(tokenAdrToReceiveProof, claimId);
      } else {
        string memory message = string(abi.encodePacked(
          Fin4TokenStrut(tokenAdrToReceiveProof).name(), ", claim #", uint2str(claimId),
          ": The quantity you are claiming would take you beyond the allowed amount for the given interval. Interval: ",
          uint2str(_getInterval(tokenAdrToReceiveProof) / 1000), "s, max. quantity: ",
          uint2str(_getMaxQuantity(tokenAdrToReceiveProof))
        ));
        Fin4Messages(_Fin4MessagesAddr()).addMessage(uint(messageType), msg.sender, msg.sender, message, address(this));
      }
      return true;
    }

    function requirementMet(address tokenAddressUsingThisProofType, address claimer, uint claimId) private view returns(bool) {
      uint sum;
      uint requestedQuantity;
      (sum, requestedQuantity) = Fin4TokenStrut(tokenAddressUsingThisProofType)
        .sumUpQuantitiesWithinIntervalBeforeThisClaim(claimer, claimId, _getInterval(tokenAddressUsingThisProofType));
      return sum + requestedQuantity <= _getMaxQuantity(tokenAddressUsingThisProofType);
    }

    // @Override
    function getSubmitProofMethodArgsCount() public view returns(uint) {
      return 2;
    }

    // @Override
    function getParameterForActionTypeCreatorToSetEncoded() public view returns(string memory) {
      return "uint:interval:days,uint:maxQuantity:quantity";
    }

    function _getInterval(address token) private view returns(uint) {
      return fin4TokenToParametersSetOnThisProofType[token][0] * 24 * 60 * 60 * 1000; // from days to miliseconds
    }

    function _getMaxQuantity(address token) private view returns(uint) {
      return fin4TokenToParametersSetOnThisProofType[token][1];
    }
}
