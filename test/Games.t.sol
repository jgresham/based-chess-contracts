// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { Games, GameUpdate } from "../src/Games.sol";

address constant CREATOR = address(0x9999);
address constant PLAYER1 = address(0x1234);
address constant PLAYER2 = address(0x5678);

contract GamesTest is Test {
  Games public games;

  function setUp() public {
    games = new Games();
  }

  function test_CreateGame() public {
    uint256 gameId = games.createGame(PLAYER1, PLAYER2);
    assertEq(gameId, 0);
  }

  function test_CreateAndSyncGame() public {
    vm.startPrank(CREATOR);
    uint256 gameId = games.createGame(PLAYER1, PLAYER2);
    assertEq(gameId, 0);
    games.syncGame(gameId, "test", bytes("0x123"), PLAYER1);
    (
      uint256 id,
      address creator,
      address player1,
      address player2,
      uint8 result,
      address winner,
      GameUpdate[] memory updates
    ) = games.getGame(gameId);
    assertEq(id, gameId);
    assertEq(creator, CREATOR);
    assertEq(player1, PLAYER1);
    assertEq(player2, PLAYER2);
    assertEq(result, 0);
    assertEq(winner, address(0));
    assertEq(updates.length, 1);
    assertEq(updates[0].signature, bytes("0x123"));
    assertEq(updates[0].signer, PLAYER1);
    vm.stopPrank();
  }

  function test_CreateAndSyncChessGameState() public {
    vm.startPrank(CREATOR);
    uint256 gameId = games.createGame(
      0x101a25d0FDC4E9ACa9fA65584A28781046f1BeEe, 0x5dd926aE40ae0deD445603C07D96cFD6B27Fada1
    );
    assertEq(gameId, 0);
    games.syncGame(
      gameId,
      '[White "0x101a25d0FDC4E9ACa9fA65584A28781046f1BeEe"] [Black "0x5dd926aE40ae0deD445603C07D96cFD6B27Fada1"] [Event "7SIOGR"] [Site "Based Chess"] [Date "2025-02-20T20:18:53.754Z"] 1. g4 e5 2. f3 Qh4#',
      bytes("0x101a25d0FDC4E9ACa9fA65584A28781046f1BeEe"),
      address(0x123)
    );
    vm.stopPrank();
    (
      uint256 id,
      address creator,
      address player1,
      address player2,
      uint8 result,
      address winner,
      GameUpdate[] memory updates
    ) = games.getGame(gameId);
    assertEq(id, gameId);
    assertEq(creator, CREATOR);
    assertEq(player1, address(0x101a25d0FDC4E9ACa9fA65584A28781046f1BeEe));
    assertEq(player2, address(0x5dd926aE40ae0deD445603C07D96cFD6B27Fada1));
    assertEq(result, 0);
    assertEq(winner, address(0));
    assertEq(updates.length, 1);
    assertEq(updates[0].signature, bytes("0x101a25d0FDC4E9ACa9fA65584A28781046f1BeEe"));
    assertEq(updates[0].signer, address(0x123));
  }

  function test_CreateAndSync2ChessGameState() public {
    vm.startPrank(CREATOR);
    uint256 gameId = games.createGame(
      0x101a25d0FDC4E9ACa9fA65584A28781046f1BeEe, 0x5dd926aE40ae0deD445603C07D96cFD6B27Fada1
    );
    vm.stopPrank();
    assertEq(gameId, 0);
    vm.startPrank(0x101a25d0FDC4E9ACa9fA65584A28781046f1BeEe);
    games.syncGame(
      gameId,
      '[White "0x101a25d0FDC4E9ACa9fA65584A28781046f1BeEe"] [Black "0x5dd926aE40ae0deD445603C07D96cFD6B27Fada1"] [Event "7SIOGR"] [Site "Based Chess"] [Date "2025-02-20T20:18:53.754Z"] 1. g4 e5 2. f3 Qh4#',
      hex"9b5f6c7b35719c91cf40187236888cdaf70b97a551cc59d98ae756b10c2717263f382486567f5d6ad7ffb77becaa804a7a79982125da45df25d37ab297b6d9791b",
      address(0x123)
    );
    vm.stopPrank();
    (
      uint256 id,
      address creator,
      address player1,
      address player2,
      uint8 result,
      address winner,
      GameUpdate[] memory updates
    ) = games.getGame(gameId);
    assertEq(id, gameId);
    assertEq(creator, CREATOR);
    assertEq(updates.length, 1);
    assertEq(
      updates[0].signature,
      hex"9b5f6c7b35719c91cf40187236888cdaf70b97a551cc59d98ae756b10c2717263f382486567f5d6ad7ffb77becaa804a7a79982125da45df25d37ab297b6d9791b"
    );
    assertEq(updates[0].signer, address(0x123));
    assertEq(player1, address(0x101a25d0FDC4E9ACa9fA65584A28781046f1BeEe));
    assertEq(player2, address(0x5dd926aE40ae0deD445603C07D96cFD6B27Fada1));
    assertEq(result, 0);
    assertEq(winner, address(0));
  }

  // function test_CreateAndSyncChessGameStateUsingUint8ArrayForSignature() public {
  //   uint256 gameId = games.createGame(
  //     0x101a25d0FDC4E9ACa9fA65584A28781046f1BeEe, 0x5dd926aE40ae0deD445603C07D96cFD6B27Fada1
  //   );
  //   assertEq(gameId, 0);
  //   uint8[] memory sig = [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33];
  //   games.syncGame(
  //     gameId,
  //     '[White "0x101a25d0FDC4E9ACa9fA65584A28781046f1BeEe"] [Black "0x5dd926aE40ae0deD445603C07D96cFD6B27Fada1"] [Event "7SIOGR"] [Site "Based Chess"] [Date "2025-02-20T20:18:53.754Z"] 1. g4 e5 2. f3 Qh4#',
  //     sig,
  //     address(0x123)
  //   );
  //   (uint256 id, GameUpdate[] memory updates, address player1, address player2) =
  //     games.getGame(gameId);
  //   assertEq(id, gameId);
  //   assertEq(updates.length, 1);
  //   assertEq(updates[0].signature, sig);
  //   assertEq(updates[0].signer, address(0x123));
  //   assertEq(player1, address(0x101a25d0FDC4E9ACa9fA65584A28781046f1BeEe));
  //   assertEq(player2, address(0x5dd926aE40ae0deD445603C07D96cFD6B27Fada1));
  // }

  function test_RevertSyncGameNotCreated() public {
    // uint256 gameId = games.createGame(PLAYER1, PLAYER2);
    // assertEq(gameId, 0);
    vm.expectRevert("Game does not exist");
    games.syncGame(0, "test", bytes("0x123"), PLAYER1);
  }

  function test_CreateSyncAndVerifyGameWithPlayer1AsWinner() public {
    vm.startPrank(CREATOR);
    uint256 gameId = games.createGame(PLAYER1, PLAYER2);
    assertEq(gameId, 0);
    games.syncGame(gameId, "test", bytes("0x123"), PLAYER1);
    games.verifyGameUpdate(gameId, 0, 1, PLAYER1);
    (
      uint256 id,
      address creator,
      address player1,
      address player2,
      uint8 result,
      address winner,
      GameUpdate[] memory updates
    ) = games.getGame(gameId);
    assertEq(id, gameId);
    assertEq(creator, CREATOR);
    assertEq(player1, PLAYER1);
    assertEq(player2, PLAYER2);
    assertEq(result, 1);
    assertEq(winner, PLAYER1);
    assertEq(updates.length, 1);
    assertEq(updates[0].signature, bytes("0x123"));
    assertEq(updates[0].signer, PLAYER1);
    vm.stopPrank();
  }
}
