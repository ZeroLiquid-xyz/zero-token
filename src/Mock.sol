// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Mock is ERC20Burnable {
    constructor(address[] memory addresses, uint256[] memory amounts) ERC20("Mock", "MOCK") {
        _mintToAddresses(addresses, amounts);
    }

    function _mintToAddresses(address[] memory addresses, uint256[] memory amounts) internal {
        for (uint256 i = 0; i < addresses.length; i++) {
            _mint(addresses[i], amounts[i]);
        }
    }
}
