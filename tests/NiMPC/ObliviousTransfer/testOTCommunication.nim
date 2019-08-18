import unittest
import asynctest
import parties
import NiMPC/ObliviousTransfer/Sequence
import NiMPC/ObliviousTransfer/Communication

suite "oblivious transfer communication":

  var senders: seq[Sender]
  var receivers: seq[Receiver]

  setUp:
    senders = @[Sender(), Sender()]
    receivers = @[Receiver(), Receiver()]

  asynctest "can send sender messages":
    twoParties:
      let messages = senders.generateSecrets()
      await party1.send(party2, messages)
      check (await party2.receiveSenderMessages(party1)) == messages

  asynctest "can send receiver messages":
    twoParties:
      let senderMessages = senders.generateSecrets()
      let bits = generateChoiceBits(uint(4 * receivers.len))
      let messages = receivers.generateSecrets(senderMessages, bits)
      await party1.send(party2, messages)
      check (await party2.receiveReceiverMessages(party1)) == messages
