// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";
import { Zero } from "../src/Zero.sol";

contract Deployment is Script {
    Zero internal zero;

    address public constant liquidity = 0x231e5C06bA8003Ed94B561aA65dD1Dbdd20a4216;
    address public constant developmentMarketing = 0x6fF9474923510C0D41d246b9f39259cbf4E5ebA3;
    address public constant developmentVesting = 0x2F145C93612dde51bf076114Fa8d735877C6c0DF;
    address public constant governanceVesting = 0x15482e97358477DCBF23e5C8A6ECF08EF1B6Bc29;
    address public constant incentiveVesting = 0x00715b7d72803CDADe639c28050c40B226F118A1;
    address public constant contributersVesting = 0x2B9ec67d34E290Ca06bB1128A4846b2705B810DB;

    address[] internal addresses =
        [liquidity, developmentMarketing, developmentVesting, governanceVesting, incentiveVesting, contributersVesting];

    // 6000000 900000 29100000 42000000 19000000 3000000
    // 6000000000000000000000000 900000000000000000000000 29100000000000000000000000
    // 42000000000000000000000000 19000000000000000000000000 3000000000000000000000000

    uint256[] internal amounts = [
        6_000_000_000_000_000_000_000_000,
        900_000_000_000_000_000_000_000,
        29_100_000_000_000_000_000_000_000,
        42_000_000_000_000_000_000_000_000,
        19_000_000_000_000_000_000_000_000,
        3_000_000_000_000_000_000_000_000
    ];

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        zero = new Zero(addresses, amounts);

        vm.stopBroadcast();
    }
}
