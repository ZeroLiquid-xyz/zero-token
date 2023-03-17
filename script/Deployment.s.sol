// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";
import { Mock } from "../src/Mock.sol";

contract Deployment is Script {
    Mock internal mock;

    address public constant liquidity = 0x228dF277C9aD435649F50D031EEeB4f5a658DB1d;
    address public constant foundation = 0x05082bFA5310b405Bc20DE4E0293FBF4cAF45f2F;
    address public constant developmentMarketing = 0x692125FE9c5761eAc0674E54b43bF2885287d8a0;
    address public constant developmentVesting = 0xc892f388B794aEBb963dEb79da3e598047d3e1c8;
    address public constant governanceVesting = 0x45CaE471F559c2be2A2737631EA2C5AdDE6177d3;
    address public constant incentiveVesting = 0xbB5809756E049Fe427a4bC5e1a6A449385a212b3;
    address public constant contributersVesting = 0x88043b288ed6A60DA7e851dE98091f3Bed5b738d;

    address[] internal addresses = [
        liquidity,
        foundation,
        developmentMarketing,
        developmentVesting,
        governanceVesting,
        incentiveVesting,
        contributersVesting
    ];

    // 6000000 4000000 900000 29100000 42000000 15000000 3000000
    // 6000000000000000000000000 4000000000000000000000000 900000000000000000000000 29100000000000000000000000
    // 42000000000000000000000000 15000000000000000000000000 3000000000000000000000000

    uint256[] internal amounts = [
        6_000_000_000_000_000_000_000_000,
        4_000_000_000_000_000_000_000_000,
        900_000_000_000_000_000_000_000,
        29_100_000_000_000_000_000_000_000,
        42_000_000_000_000_000_000_000_000,
        15_000_000_000_000_000_000_000_000,
        3_000_000_000_000_000_000_000_000
    ];

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        mock = new Mock(addresses, amounts);

        vm.stopBroadcast();
    }
}
