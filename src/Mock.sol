// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Mock is ERC20Burnable {
    // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
    bytes32 private constant EIP712DOMAIN_HASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    // bytes32 private constant NAME_HASH = keccak256("Mock")
    bytes32 private constant NAME_HASH = 0xb6719659e1320df3593ef1d62831d5830f1fdce720f856f4e26e013032b7e58c;

    // bytes32 private constant VERSION_HASH = keccak256("1")
    bytes32 private constant VERSION_HASH = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    // ERC-2612 state
    mapping(address => uint256) public nonces;

    constructor(address[] memory addresses, uint256[] memory amounts) ERC20("Mock", "MOCK") {
        _mintToAddresses(addresses, amounts);
    }

    function _mintToAddresses(address[] memory addresses, uint256[] memory amounts) internal {
        for (uint256 i = 0; i < addresses.length; i++) {
            _mint(addresses[i], amounts[i]);
        }
    }

    function _validateSignedData(address signer, bytes32 encodeData, uint8 v, bytes32 r, bytes32 s) internal view {
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", getDomainSeparator(), encodeData));
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signer, "Mock:: INVALID_SIGNATURE");
    }

    function getDomainSeparator() public view returns (bytes32) {
        return keccak256(abi.encode(EIP712DOMAIN_HASH, NAME_HASH, VERSION_HASH, getChainId(), address(this)));
    }

    function getChainId() public view returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }

    function mint(address to, uint256 value) external {
        _mint(to, value);
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        require(deadline >= block.timestamp, "Mock:: AUTH_EXPIRED");

        bytes32 encodeData = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner], deadline));
        nonces[owner] = nonces[owner] + 1;
        _validateSignedData(owner, encodeData, v, r, s);

        _approve(owner, spender, value);
    }
}
