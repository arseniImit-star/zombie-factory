// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ZombieFactory} from "../src/ZombieFactory.sol";

contract ZombieFactoryTest is Test {
    ZombieFactory factory;

    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    // Выполняется перед каждым тестом
    function setUp() public {
        factory = new ZombieFactory();
    }

    // ТЕСТ 1: создание зомби
    function testCreateZombie() public {
        vm.prank(alice);

        uint256 id = factory.createZombie("Alice");

        assertEq(id, 0);
        assertEq(factory.totalZombies(), 1);
        assertEq(factory.zombieToOwner(id), alice);
        assertEq(factory.ownerZombieCount(alice), 1);

        (string memory name, uint256 dna, uint256 createdAt) = factory.getZombie(id);

        assertEq(name, "Alice");
        assertLt(dna, factory.DNA_MODULUS());
        assertEq(createdAt, block.timestamp);
    }

    // ТЕСТ 2: два разных пользователя
    function testTwoDifferentOwners() public {
        vm.prank(alice);
        uint256 id1 = factory.createZombie("Alice");

        vm.prank(bob);
        uint256 id2 = factory.createZombie("Bob");

        assertEq(id1, 0);
        assertEq(id2, 1);

        assertEq(factory.zombieToOwner(id1), alice);
        assertEq(factory.zombieToOwner(id2), bob);

        assertEq(factory.totalZombies(), 2);
    }

    // ТЕСТ 3: запрет пустого имени
    function testEmptyNameReverts() public {
        vm.prank(alice);

        vm.expectRevert(abi.encodeWithSignature("Error(string)", "Empty name"));

        factory.createZombie("");
    }

    // ТЕСТ 4: запрет второго зомби
    function testCannotCreateSecondZombie() public {
        vm.startPrank(alice);

        factory.createZombie("First");

        vm.expectRevert(abi.encodeWithSignature("Error(string)", "Already has zombie"));

        factory.createZombie("Second");

        vm.stopPrank();
    }

    // ТЕСТ 5: проверка диапазона ДНК
    function testDnaIsWithinRange() public {
        vm.prank(alice);

        uint256 id = factory.createZombie("Alice");

        (, uint256 dna,) = factory.getZombie(id);

        assertLt(dna, factory.DNA_MODULUS());
    }
}
