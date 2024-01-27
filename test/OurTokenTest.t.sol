// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";

contract OurTokenTest is Test {
    OurToken ourToken;
    DeployOurToken deployOurToken;
    uint256 initialSupply;
    uint256 private constant FUND_USER = 1 ether;

    address BOB = makeAddr("BOB");
    address ALEX = makeAddr("ALEX");
    address deployerAddress;

    function setUp() public {
        deployOurToken = new DeployOurToken();
        ourToken = deployOurToken.run();
        initialSupply = deployOurToken.INITIAL_SUPPLY();

        deployerAddress = vm.addr(deployOurToken.deployerKey());
        console.log("msg.sender balance", ourToken.balanceOf(deployerAddress));
        vm.prank(deployerAddress);
        ourToken.transfer(BOB, FUND_USER);
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), initialSupply);
    }

    function testBobBalance() public {
        assertEq(ourToken.balanceOf(BOB), FUND_USER);
    }

    function testAllowanceAndTransfer() public {
        // Approve tokens from BOB to ALEX
        vm.prank(BOB);
        ourToken.approve(ALEX, 100);
        assertEq(ourToken.allowance(BOB, ALEX), 100);

        // Transfer tokens from BOB to ALEX
        vm.prank(ALEX);
        ourToken.transferFrom(BOB, ALEX, 100);
        assertEq(ourToken.balanceOf(ALEX), 100);
    }

    function testTransferFromOwner() public {
        uint256 initialOwnerBalance = ourToken.balanceOf(deployerAddress);

        vm.prank(deployerAddress);
        ourToken.transfer(ALEX, 50);

        assertEq(ourToken.balanceOf(deployerAddress), initialOwnerBalance - 50);
        assertEq(ourToken.balanceOf(ALEX), 50);
    }

    function testTransferFailsWithInsufficientBalance() public {
        vm.prank(BOB);
        uint256 initialBobBalance = ourToken.balanceOf(BOB);

        // Attempt to transfer more than available balance
        vm.expectRevert();
        ourToken.transfer(ALEX, initialBobBalance + 1);

        // assertEq(transferResult, false);
        assertEq(ourToken.balanceOf(BOB), initialBobBalance);
        assertEq(ourToken.balanceOf(ALEX), 0); // Unchanged from previous test
    }
}
