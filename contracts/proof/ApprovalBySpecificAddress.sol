pragma solidity ^0.5.0;

import "contracts/proof/Fin4BaseProofType.sol";
import "contracts/proof/modules/ApprovalByOneAddress.sol";

contract ApprovalBySpecificAddress is Fin4BaseProofType, ApprovalByOneAddress {

  constructor()
    Fin4BaseProofType("ApprovalBySpecificAddress", "The specified address has to approve")
    public {}

  function submitProof(address tokenAdrToReceiveProof, uint claimId, address approver) public returns(bool) {
    PendingApproval storage pa = pendingApprovals[approver];
    pa.tokenAdrToReceiveProof = tokenAdrToReceiveProof;
    pa.claimIdOnTokenToReceiveProof = claimId;
    pa.requester = msg.sender;
    pa.approver = approver;
    return true;
  }

}
