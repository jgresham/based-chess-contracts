// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

struct GameUpdate {
  bytes signature;
  address signer;
}

struct Game {
  uint256 id;
  address creator;
  address player1;
  address player2;
  GameUpdate[] updates;
  // 3rd party verifications of (game state) updates
  mapping(address => uint8[]) updateVerifications;
}

contract Games {
  Game[] games;

  event GameCreated(uint256 indexed gameId);
  event GameUpdateSynced(uint256 indexed gameId, string message, bytes signature, address signer);

  function createGame(address player1, address player2) public returns (uint256) {
    require(player1 != address(0) && player2 != address(0), "Player addresses cannot be 0");
    // Create a new Game struct in storage
    Game storage newGame = games.push(); // Push an empty struct and get a reference to it

    // Initialize the fields
    newGame.id = games.length - 1; // Since push increases length after adding
    newGame.creator = msg.sender;
    newGame.player1 = player1;
    newGame.player2 = player2;

    emit GameCreated(newGame.id);

    return newGame.id;
  }

  function syncGame(uint256 id, string memory message, bytes memory signature, address signer)
    public
    returns (uint256)
  {
    require(id < games.length, "Game does not exist");
    // require msg.sender to be creator, player1, or player2
    require(
      msg.sender == games[id].creator || msg.sender == games[id].player1
        || msg.sender == games[id].player2,
      "You are not allowed to sync this game"
    );
    // We can verify the signature offchain when verifyGameUpdate is called
    games[id].updates.push(GameUpdate({ signature: signature, signer: signer }));
    emit GameUpdateSynced(id, message, signature, signer);

    return id;
  }

  // anyone can verify a game update
  function verifyGameUpdate(uint256 id, uint8 updateVerified) public {
    require(id < games.length, "Game does not exist");
    games[id].updateVerifications[msg.sender].push(updateVerified);
  }

  function getGame(uint256 id) public view returns (uint256, GameUpdate[] memory, address, address) {
    require(id < games.length, "Game does not exist");
    return (games[id].id, games[id].updates, games[id].player1, games[id].player2);
  }

  function getGameUpdateVerificationsByVerifier(uint256 id, address verifier)
    public
    view
    returns (uint8[] memory)
  {
    require(id < games.length, "Game does not exist");
    return games[id].updateVerifications[verifier];
  }
}
