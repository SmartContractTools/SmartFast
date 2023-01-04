from collections import namedtuple
from typing import List

ERC = namedtuple("ERC", ["name", "parameters", "return_type", "view", "required", "events"])
ERC_EVENT = namedtuple("ERC_EVENT", ["name", "parameters", "indexes"])


def erc_to_signatures(erc: List[ERC]):
    """
    Return the list of mandatory signatures
    :param erc:
    :return:
    """
    return [f'{e.name}({",".join(e.parameters)})' for e in erc if e.required]


# Final
# https://eips.ethereum.org/EIPS/eip-20

ERC20_transfer_event = ERC_EVENT("Transfer", ["address", "address", "uint256"], [True, True, False])
ERC20_approval_event = ERC_EVENT("Approval", ["address", "address", "uint256"], [True, True, False])
ERC20_EVENTS = [ERC20_transfer_event, ERC20_approval_event]

ERC20 = [
    ERC("totalSupply", [], "uint256", True, True, []),
    ERC("balanceOf", ["address"], "uint256", True, True, []),
    ERC("transfer", ["address", "uint256"], "bool", False, True, [ERC20_transfer_event]),
    ERC(
        "transferFrom",
        ["address", "address", "uint256"],
        "bool",
        False,
        True,
        [ERC20_transfer_event],
    ),
    ERC("approve", ["address", "uint256"], "bool", False, True, [ERC20_approval_event]),
    ERC("allowance", ["address", "address"], "uint256", True, True, []),
]

ERC20_OPTIONAL = [
    ERC("name", [], "string", True, False, []),
    ERC("symbol", [], "string", True, False, []),
    ERC("decimals", [], "uint8", True, False, []),
]

ERC20 = ERC20 + ERC20_OPTIONAL

ERC20_signatures = erc_to_signatures(ERC20)

# Draft
# https://github.com/ethereum/eips/issues/223

ERC223_transfer_event = ERC_EVENT(
    "Transfer", ["address", "address", "uint256", "bytes"], [True, True, False, False]
)

ERC223_EVENTS = [ERC223_transfer_event]

ERC223 = [
    ERC("name", [], "string", True, True, []),
    ERC("symbol", [], "string", True, True, []),
    ERC("decimals", [], "uint8", True, True, []),
    ERC("totalSupply", [], "uint256", True, True, []),
    ERC("balanceOf", ["address"], "uint256", True, True, []),
    ERC("transfer", ["address", "uint256"], "bool", False, True, [ERC223_transfer_event]),
    ERC("transfer", ["address", "uint256", "bytes"], "bool", False, True, [ERC223_transfer_event],),
    ERC(
        "transfer",
        ["address", "uint256", "bytes", "string"],
        "bool",
        False,
        True,
        [ERC223_transfer_event],
    ),
]
ERC223_signatures = erc_to_signatures(ERC223)

# Final
# https://eips.ethereum.org/EIPS/eip-165

ERC165_EVENTS: List = []

ERC165 = [ERC("supportsInterface", ["bytes4"], "bool", True, True, [])]
ERC165_signatures = erc_to_signatures(ERC165)

# Final
# https://eips.ethereum.org/EIPS/eip-721
# Must have ERC165

ERC721_transfer_event = ERC_EVENT("Transfer", ["address", "address", "uint256"], [True, True, True])
ERC721_approval_event = ERC_EVENT("Approval", ["address", "address", "uint256"], [True, True, True])
ERC721_approvalforall_event = ERC_EVENT(
    "ApprovalForAll", ["address", "address", "bool"], [True, True, False]
)
ERC721_EVENTS = [
    ERC721_transfer_event,
    ERC721_approval_event,
    ERC721_approvalforall_event,
]

ERC721 = [
    ERC("balanceOf", ["address"], "uint256", True, True, []),
    ERC("ownerOf", ["uint256"], "address", True, True, []),
    ERC(
        "safeTransferFrom",
        ["address", "address", "uint256", "bytes"],
        "",
        False,
        True,
        [ERC721_transfer_event],
    ),
    ERC(
        "safeTransferFrom",
        ["address", "address", "uint256"],
        "",
        False,
        True,
        [ERC721_transfer_event],
    ),
    ERC(
        "transferFrom", ["address", "address", "uint256"], "", False, True, [ERC721_transfer_event],
    ),
    ERC("approve", ["address", "uint256"], "", False, True, [ERC721_approval_event]),
    ERC("setApprovalForAll", ["address", "bool"], "", False, True, [ERC721_approvalforall_event],),
    ERC("getApproved", ["uint256"], "address", True, True, []),
    ERC("isApprovedForAll", ["address", "address"], "bool", True, True, []),
] + ERC165

ERC721_OPTIONAL = [
    ERC("name", [], "string", True, False, []),
    ERC("symbol", [], "string", False, False, []),
    ERC("tokenURI", ["uint256"], "string", False, False, []),
]

ERC721 = ERC721 + ERC721_OPTIONAL

ERC721_signatures = erc_to_signatures(ERC721)

# Final
# https://eips.ethereum.org/EIPS/eip-1820
ERC1820_EVENTS: List = []
ERC1820 = [
    ERC("canImplementInterfaceForAddress", ["bytes32", "address"], "bytes32", True, True, [],)
]
ERC1820_signatures = erc_to_signatures(ERC1820)

# Last Call
# https://eips.ethereum.org/EIPS/eip-777
ERC777_sent_event = ERC_EVENT(
    "Sent",
    ["address", "address", "address", "uint256", "bytes", "bytes"],
    [True, True, True, False, False, False],
)
ERC777_minted_event = ERC_EVENT(
    "Minted",
    ["address", "address", "uint256", "bytes", "bytes"],
    [True, True, False, False, False],
)
ERC777_burned_event = ERC_EVENT(
    "Burned",
    ["address", "address", "uint256", "bytes", "bytes"],
    [True, True, False, False, False],
)
ERC777_authorizedOperator_event = ERC_EVENT(
    "AuthorizedOperator", ["address", "address"], [True, True]
)
ERC777_revokedoperator_event = ERC_EVENT("RevokedOperator", ["address", "address"], [True, True])
ERC777_EVENTS = [
    ERC777_sent_event,
    ERC777_minted_event,
    ERC777_burned_event,
    ERC777_authorizedOperator_event,
    ERC777_revokedoperator_event,
]

ERC777 = [
    ERC("name", [], "string", True, True, []),
    ERC("symbol", [], "string", True, True, []),
    ERC("totalSupply", [], "uint256", True, True, []),
    ERC("balanceOf", ["address"], "uint256", True, True, []),
    ERC("granularity", [], "uint256", True, True, []),
    ERC("defaultOperators", [], "address[]", True, True, []),
    ERC("isOperatorFor", ["address", "address"], "bool", True, True, []),
    ERC("authorizeOperator", ["address"], "", False, True, [ERC777_authorizedOperator_event],),
    ERC("revokeOperator", ["address"], "", False, True, [ERC777_revokedoperator_event]),
    ERC("send", ["address", "uint256", "bytes"], "", False, True, [ERC777_sent_event]),
    ERC(
        "operatorSend",
        ["address", "address", "uint256", "bytes", "bytes"],
        "",
        False,
        True,
        [ERC777_sent_event],
    ),
    ERC("burn", ["uint256", "bytes"], "", False, True, [ERC777_burned_event]),
    ERC(
        "operatorBurn",
        ["address", "uint256", "bytes", "bytes"],
        "",
        False,
        True,
        [ERC777_burned_event],
    ),
]
ERC777_signatures = erc_to_signatures(ERC777)

# ERC621
ERC621_transfer_event = ERC_EVENT("Transfer", ["address", "address", "uint256"], [True, True, False])
ERC621_approval_event = ERC_EVENT("Approval", ["address", "address", "uint256"], [True, True, False])
ERC621_EVENTS = [ERC621_transfer_event, ERC621_approval_event] #event事件

ERC621 = [
    ERC("totalSupply", [], "uint256", True, True, []),
    ERC("balanceOf", ["address"], "uint256", True, True, []),
    ERC("transfer", ["address", "uint256"], "bool", False, True, [ERC621_transfer_event]),
    ERC(
        "transferFrom",
        ["address", "address", "uint256"],
        "bool",
        False,
        True,
        [ERC621_transfer_event],
    ),
    ERC("approve", ["address", "uint256"], "bool", False, True, [ERC621_approval_event]),
    ERC("allowance", ["address", "address"], "uint256", True, True, []),
    ERC("increaseSupply", ["uint256", "address"], "bool", True, True, []),
    ERC("safeAdd", ["uint256", "uint256"], "uint256", True, True, []),
    ERC("decreaseSupply", ["uint256", "address"], "bool", True, True, []),
    ERC("safeSub", ["uint256", "uint256"], "uint256", True, True, []),
]

ERC621_OPTIONAL = [
    ERC("name", [], "string", True, False, []),
    ERC("symbol", [], "string", True, False, []),
    ERC("decimals", [], "uint8", True, False, []),
]

ERC621 = ERC621 + ERC621_OPTIONAL

ERC621_signatures = erc_to_signatures(ERC621)

# ERC875
ERC875_transfer_event = ERC_EVENT("Transfer", ["address", "address", "uint256"], [True, True, False])
ERC875_approval_event = ERC_EVENT("Approval", ["address", "address", "uint256"], [True, True, False])
ERC875_EVENTS = [ERC875_transfer_event, ERC875_approval_event] #event事件

ERC875 = [
    ERC("name", [], "string", False, True, []),
    ERC("symbol", [], "string", False, True, []),
    ERC("balanceOf", ["address"], "uint256[]", True, True, []),
    ERC(
        "transferFrom",
        ["address", "address", "uint256[]"],
        "",
        False,
        True,
        [],
    ),
    ERC("transfer", ["address", "uint256[]"], "", False, True, [ERC875_transfer_event]),
]

ERC875_OPTIONAL = [
    ERC("totalSupply", [], "uint256", True, False, []),
    ERC("trade", ["uint256","uint256[]","uint8","bytes32","bytes32"], "", False, False, []),
    ERC("ownerOf", ["uint256 "], "address", True, False, []),
]

ERC875 = ERC875 + ERC875_OPTIONAL

ERC875_signatures = erc_to_signatures(ERC875)

# ERC1155
ERC1155_transfersingle_event = ERC_EVENT("TransferSingle", ["address", "address", "address", "uint256", "uint256"], [True, True, True, False, False])
ERC1155_transferbatch_event = ERC_EVENT("TransferBatch", ["address", "address", "address", "uint256[]", "uint256[]"], [True, True, True, False, False])
ERC1155_approvalforall_event = ERC_EVENT("ApprovalForAll", ["address", "address", "bool"], [True, True, False])
ERC1155_uri_event = ERC_EVENT("URI", ["string", "uint256"], [False, True])
ERC1155_EVENTS = [ERC1155_transfersingle_event, ERC1155_transferbatch_event, ERC1155_approvalforall_event, ERC1155_uri_event] #event事件

ERC1155 = [
    ERC("safeTransferFrom", ["address","address","uint256","uint256","bytes"], "", False, True, []),
    ERC("safeBatchTransferFrom", ["address","address","uint256[]","uint256[]","bytes"], "", False, True, []),
    ERC("balanceOf", ["address","uint256"], "uint256", True, True, []),
    ERC(
        "balanceOfBatch",
        ["address[]", "uint256[]"],
        "uint256[]",
        True,
        True,
        [],
    ),
    ERC("setApprovalForAll", ["address", "bool"], "", False, True, []),
    ERC("isApprovedForAll", ["address", "address"], "bool", True, True, []),
]

ERC1155_signatures = erc_to_signatures(ERC1155)

# ERC1190
ERC1190_approval_event = ERC_EVENT("Approval", ["address[]", "address[]", "uint256"], [True, True, True])
ERC1190_creativelicensetransferred_event = ERC_EVENT("CreativeLicenseTransferred", ["address[]", "address[]", "uint256"], [True, True, True])
ERC1190_ownershiplicensetransferred_event = ERC_EVENT("OwnershipLicenseTransferred", ["address[]", "address[]", "address[]", "uint256"], [True, True, True, True])
ERC1190_assetrented_event = ERC_EVENT("AssetRented", ["address[]", "address[]", "address[]", "uint256"], [True, True, True, True])
ERC1190_EVENTS = [ERC1190_approval_event, ERC1190_creativelicensetransferred_event, ERC1190_ownershiplicensetransferred_event, ERC1190_assetrented_event] #event事件

ERC1190 = [
    ERC("approve", ["address[]","uint256","uint256"], "uint256", False, True, [ERC1190_approval_event]),
    ERC("transferCreativeLicense", ["address[]","address[]","uint256"], "", False, True, [ERC1190_creativelicensetransferred_event]),
    ERC("transferOwnershipLicense", ["address[]","address[]","address[]","uint256"], "", False, True, [ERC1190_ownershiplicensetransferred_event]),
    ERC("rentAsset", ["address[]", "address[]", "address[]", "uint256"], "", False, True, [ERC1190_assetrented_event]),
]

ERC1190_signatures = erc_to_signatures(ERC1190)

# ERC1410
ERC1410_transferbypartition_event = ERC_EVENT("TransferByPartition", ["bytes32","address","address","address","uint256","bytes","bytes"], [True, False, True, True, False, False, False])
ERC1410_authorizedoperator_event = ERC_EVENT("AuthorizedOperator", ["address","address"], [True, True])
ERC1410_revokedoperator_event = ERC_EVENT("RevokedOperator", ["address","address"], [True, True])
ERC1410_authorizedoperatorbypartition_event = ERC_EVENT("AuthorizedOperatorByPartition", ["bytes32","address","address"], [True, True, True])
ERC1410_rvokedoperatorbypartition_event = ERC_EVENT("RevokedOperatorByPartition", ["bytes32","address","address"], [True, True, True])
ERC1410_issuedbypartition_event = ERC_EVENT("IssuedByPartition", ["bytes32","address","address","uint256","bytes","bytes"], [True, True, True, False, False, False])
ERC1410_redeemedbypartition_event = ERC_EVENT("RedeemedByPartition", ["bytes32","address","address","uint256","bytes"], [True, True, True, False, False])
ERC1410_EVENTS = [ERC1410_transferbypartition_event, ERC1410_authorizedoperator_event, ERC1410_revokedoperator_event, ERC1410_authorizedoperatorbypartition_event, ERC1410_rvokedoperatorbypartition_event, ERC1410_issuedbypartition_event, ERC1410_redeemedbypartition_event] #event事件

ERC1410 = [
    ERC("balanceOf", ["address"], "uint256", True, True, []),
    ERC("balanceOfByPartition", ["bytes32","address"], "uint256", True, True, []),
    ERC("partitionsOf", ["address"], "bytes32[]", True, True, []),
    ERC("totalSupply", [], "uint256", True, True, []),
    ERC("transferByPartition", ["bytes32", "address", "uint256", "bytes"], "bytes32", False, True, [ERC1410_transferbypartition_event]),
    ERC("operatorTransferByPartition", ["bytes32", "address", "address", "uint256", "bytes", "bytes"], "bytes32", False, True, []),
    ERC("canTransferByPartition", ["address", "address", "bytes32", "uint256", "bytes"], ["bytes1", "bytes32", "bytes32"], True, True, []),
    ERC("isOperator", ["address", "address"], "bool", True, True, []),
    ERC("isOperatorForPartition", ["bytes32", "address", "address"], "bool", True, True, []),
    ERC("authorizeOperator", ["address"], "", False, True, [ERC1410_authorizedoperator_event]),
    ERC("revokeOperator", ["address"], "", False, True, [ERC1410_revokedoperator_event]),
    ERC("authorizeOperatorByPartition", ["bytes32", "address"], "", False, True, [ERC1410_authorizedoperatorbypartition_event]),
    ERC("revokeOperatorByPartition", ["bytes32", "address"], "", False, True, [ERC1410_rvokedoperatorbypartition_event]),
    ERC("issueByPartition", ["bytes32", "address", "uint256", "bytes"], "", False, True, [ERC1410_issuedbypartition_event]),
    ERC("redeemByPartition", ["bytes32", "uint256", "bytes"], "", False, True, [ERC1410_redeemedbypartition_event]),
    ERC("operatorRedeemByPartition", ["bytes32", "address", "uint256", "bytes"], "", False, True, []),
]

ERC1410_signatures = erc_to_signatures(ERC1410)


ERCS = {
    "ERC20": (ERC20, ERC20_EVENTS),
    "ERC223": (ERC223, ERC223_EVENTS),
    "ERC165": (ERC165, ERC165_EVENTS),
    "ERC721": (ERC721, ERC721_EVENTS),
    "ERC1820": (ERC1820, ERC1820_EVENTS),
    "ERC777": (ERC777, ERC777_EVENTS),
    "ERC621": (ERC621, ERC621_EVENTS),
    "ERC875": (ERC875, ERC875_EVENTS),
    "ERC1155": (ERC1155, ERC1155_EVENTS),
    "ERC1190": (ERC1190, ERC1190_EVENTS),
    "ERC1410": (ERC1410, ERC1410_EVENTS)
}
