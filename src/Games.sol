// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

uint8 constant NO_RESULT = 0;
uint8 constant WINNING_RESULT = 1;
uint8 constant DRAW_RESULT_AGREEMENT = 2;
uint8 constant DRAW_RESULT_STALEMATE = 3;
uint8 constant DRAW_RESULT_THREEFOLD_REPETITION = 4;

struct GameUpdate {
  bytes signature;
  address signer;
}

struct Game {
  uint256 id;
  address creator;
  address player1;
  address player2;
  uint8 result;
  address winner;
  GameUpdate[] updates;
  // 3rd party verifications of (game state) updates
  mapping(address => uint8[]) updateVerifications;
}

contract Games {
  Game[] games;

  event GameCreated(uint256 indexed gameId);
  event GameUpdateSynced(
    uint256 indexed gameId, string message, bytes signature, address signer, uint8 updateIndex
  );
  event GameOver(uint256 indexed gameId, uint8 result, address winner);

  function createGame(address player1, address player2) public returns (uint256) {
    require(player1 != address(0) && player2 != address(0), "Player addresses cannot be 0");
    require(player1 != player2, "Player addresses cannot be the same");

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
    // if a player is spamming more than 225 updates, then they will be marked as spamming
    emit GameUpdateSynced(id, message, signature, signer, uint8(games[id].updates.length - 1));

    return id;
  }

  // anyone can verify a game update, only the creator can set the result and winner
  function verifyGameUpdate(uint256 id, uint8 updateVerified, uint8 result, address winner) public {
    require(id < games.length, "Game does not exist");
    require(updateVerified < games[id].updates.length, "Update does not exist");
    games[id].updateVerifications[msg.sender].push(updateVerified);
    if (msg.sender == games[id].creator) {
      // result != 0 means the game is over
      if (result != 0) {
        games[id].result = result;
        emit GameOver(id, result, winner);
      }
      if (winner != address(0) && result == WINNING_RESULT) {
        require(
          winner == games[id].player1 || winner == games[id].player2, "Winner must be a player"
        );
        games[id].winner = winner;
      }
    }
  }

  function getGame(uint256 id)
    public
    view
    returns (uint256, address, address, address, uint8, address, GameUpdate[] memory)
  {
    require(id < games.length, "Game does not exist");
    return (
      games[id].id,
      games[id].creator,
      games[id].player1,
      games[id].player2,
      games[id].result,
      games[id].winner,
      games[id].updates
    );
  }

  function isWinner(uint256 gameId, address player) public view returns (bool) {
    require(gameId < games.length, "Game does not exist");
    return games[gameId].winner == player;
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
