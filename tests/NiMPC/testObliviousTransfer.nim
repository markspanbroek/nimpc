import unittest
import asynctest
import parties
import NiMPC/Parties
import NiMPC/ObliviousTransfer

suite "oblivious transfer between two parties":
  var receiverKeys, senderKeys0, senderKeys1: seq[Key]
  var choiceBits: seq[bool]

  proc checkKeyLengths(length: int) =
    check senderKeys0.len == length
    check senderKeys1.len == length
    check receiverKeys.len == length
    check choiceBits.len == length

  suite "default amount":

    asyncsetup:
      twoParties:
        choiceBits = generateChoiceBits()
        let senderTransfer = party1.sendOT(party2)
        let receiverTransfer = party2.receiveOT(party1, choiceBits)
        (senderKeys0, senderKeys1) = await senderTransfer
        receiverKeys = await receiverTransfer

    test "returns 4 keys":
      checkKeyLengths 4

    test "generates unique sender keys":
      check senderKeys0 != senderKeys1

  suite "any amount":

    proc performOT(amount: uint) {.async.} =
      twoParties:
        choiceBits = generateChoiceBits(amount)
        let senderTransfer = party1.sendOT(party2, amount)
        let receiverTransfer = party2.receiveOT(party1, choiceBits)
        (senderKeys0, senderKeys1) = await senderTransfer
        receiverKeys = await receiverTransfer

    asynctest "returns multiples of 4 keys":
      await performOT(8)
      checkKeyLengths 8

    asynctest "raises when number of keys is not a multiple of 4":
      expect Exception:
        await performOT(7)

    asynctest "choice bits indicate which sender key has been chosen":
      await performOT(8)
      for i in 0..<choiceBits.len:
        if choiceBits[i]:
          check receiverKeys[i] == senderKeys1[i]
        else:
          check receiverKeys[i] == senderKeys0[i]
