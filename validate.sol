// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Node {
    struct NodeInfo {
        address metamaskId;
        string collegeName;
        string branch;
        string ipfsHash;
    }
NodeInfo[] nodes;
mapping(bytes32 => bool) nodeExists;
mapping(address => uint256[]) nodeIds;

event NodeCreated(address indexed sender, uint256 indexed nodeId);
event IpfsHashAdded(address indexed sender, uint256 indexed nodeId);
function createNode(address _metamaskId, string memory _collegeName, string memory _branch) public payable returns (uint256) {
    bytes32 nodeHash = keccak256(abi.encodePacked(_metamaskId, _branch));
    require(!nodeExists[nodeHash], "Node with this Metamask ID and branch already exists");

    NodeInfo memory newNode = NodeInfo(_metamaskId, _collegeName, _branch, "");
    uint256 nodeId = nodes.length;
    nodes.push(newNode);
    nodeExists[nodeHash] = true;
    nodeIds[_metamaskId].push(nodeId);

    emit NodeCreated(msg.sender, nodeId);

    return nodeId;
}

function getNodeCount() public view returns (uint256) {
    return nodes.length;
}

function getNodeByMetamaskId(address _metamaskId) public view returns (NodeInfo[] memory) {
    uint256[] memory nodeIdsArray = nodeIds[_metamaskId];
    require(nodeIdsArray.length > 0, "Node with this Metamask ID does not exist");
    NodeInfo[] memory resultNodes = new NodeInfo[](nodeIdsArray.length);
    for (uint i = 0; i < nodeIdsArray.length; i++) {
        NodeInfo memory node = nodes[nodeIdsArray[i]];
        require(node.metamaskId == _metamaskId, "Node with this Metamask ID does not exist");
        resultNodes[i] = node;
    }
    return resultNodes;
}

function addIpfsHash(address _metamaskId, string memory _ipfsHash) public {
    uint256[] memory nodeIdsArray = nodeIds[_metamaskId];
    require(nodeIdsArray.length > 0, "Node with this Metamask ID does not exist");
    for (uint i = 0; i < nodeIdsArray.length; i++) {
        NodeInfo storage node = nodes[nodeIdsArray[i]];
        require(node.metamaskId == _metamaskId, "Node with this Metamask ID does not exist");
        if (keccak256(abi.encodePacked(node.ipfsHash)) == keccak256(abi.encodePacked(_ipfsHash))) {
            // IPFS hash already exists in this node, return status
            revert("IPFS hash already exists in this node");
        }
        node.ipfsHash = _ipfsHash;
        emit IpfsHashAdded(msg.sender, nodeIdsArray[i]);
    }
}


function validate(string memory _ipfsCid) public view returns (string memory) {
    for (uint i = 0; i < nodes.length; i++) {
        if (keccak256(abi.encodePacked(nodes[i].ipfsHash)) == keccak256(abi.encodePacked(_ipfsCid))) {
            return "success";
        }
    }
    return "not found";
}
}