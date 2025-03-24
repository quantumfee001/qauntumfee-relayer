// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract GasFeeManager {
    address public owner;
    address public qftToken;
    uint256 public qftPerGasUnit = 1e15; // 0.001 QFT per gas unit (adjustable)
    mapping(address => uint256) public nonces; // To prevent replay attacks

    event GasFeePaid(address indexed user, uint256 qftAmount, uint256 ethSent);

    // EIP-712 Domain Separator
    bytes32 private constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );
    bytes32 private constant EXECUTE_TYPEHASH = keccak256(
        "Execute(address user,address to,uint256 value,uint256 nonce)"
    );
    bytes32 private DOMAIN_SEPARATOR;

    constructor(address _qftToken) {
        owner = msg.sender;
        qftToken = _qftToken;
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712DOMAIN_TYPEHASH,
                keccak256(bytes("GasFeeManager")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    // Allow contract to receive ETH
    receive() external payable {}

    function executeMetaTransaction(
        address user,
        address to,
        uint256 value,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // Verify signature
        bytes32 structHash = keccak256(
            abi.encode(
                EXECUTE_TYPEHASH,
                user,
                to,
                value,
                nonces[user]
            )
        );
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                structHash
            )
        );
        address signer = ecrecover(digest, v, r, s);
        require(signer == user, "Invalid signature");
        require(signer != address(0), "Invalid signer");

        // Increment nonce to prevent replay
        nonces[user]++;

        // Execute transaction
        IERC20 token = IERC20(qftToken);
        uint256 gasEstimate = 50000; // Adjust based on actual usage
        uint256 qftCost = gasEstimate * qftPerGasUnit;

        require(token.balanceOf(user) >= qftCost, "Insufficient QFT balance");
        require(token.transferFrom(user, owner, qftCost), "QFT transfer failed");

        (bool success, ) = to.call{value: value}("");
        require(success, "ETH transfer failed");

        emit GasFeePaid(user, qftCost, value);
    }

    function getNonce(address user) external view returns (uint256) {
        return nonces[user];
    }

    function updateQftPerGasUnit(uint256 newRate) external {
        require(msg.sender == owner, "Only owner");
        qftPerGasUnit = newRate;
    }

    function withdrawETH(address payable to, uint256 amount) external {
        require(msg.sender == owner, "Only owner");
        require(address(this).balance >= amount, "Insufficient ETH balance");
        (bool success, ) = to.call{value: amount}("");
        require(success, "ETH withdrawal failed");
    }
}