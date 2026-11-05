// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ZombieFactory {
    // Структура зомби
    struct Zombie {
        string name;
        uint256 dna;
        uint256 createdAt;
    }

    // Максимальное значение ДНК
    uint256 public constant DNA_MODULUS = 10 ** 16;

    // Массив всех зомби
    Zombie[] private zombies;

    // Связь ID зомби с его владельцем
    mapping(uint256 => address) public zombieToOwner;

    // Количество зомби у каждого владельца
    mapping(address => uint256) public ownerZombieCount;

    // Событие создания зомби
    event ZombieCreated(uint256 indexed id, address indexed owner, string name, uint256 dna);

    // Создание нового зомби
    function createZombie(string calldata name) external returns (uint256 id) {
        // Проверяем имя
        require(bytes(name).length > 0, "Empty name");

        // Проверяем, есть ли уже зомби у пользователя
        require(ownerZombieCount[msg.sender] == 0, "Already has zombie");

        // Вычисляем ДНК
        uint256 dna = uint256(keccak256(abi.encodePacked(msg.sender, name))) % DNA_MODULUS;

        // ID нового зомби
        id = zombies.length;

        // Сохраняем зомби
        zombies.push(Zombie({name: name, dna: dna, createdAt: block.timestamp}));

        // Записываем владельца
        zombieToOwner[id] = msg.sender;

        // Увеличиваем счётчик
        ownerZombieCount[msg.sender]++;

        // Генерируем событие
        emit ZombieCreated(id, msg.sender, name, dna);
    }

    // Получение общего количества зомби
    function totalZombies() external view returns (uint256) {
        return zombies.length;
    }

    // Получение информации о зомби
    function getZombie(uint256 id) external view returns (string memory name, uint256 dna, uint256 createdAt) {
        Zombie storage zombie = zombies[id];

        return (zombie.name, zombie.dna, zombie.createdAt);
    }
}
