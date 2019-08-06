import unittest
import asynctest
import parties
import NiMPC/Communication
import NiMPC/ObliviousTransfer

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
      let (_, messages) = receivers.generateSecrets(senders.generateSecrets())
      await party1.send(party2, messages)
      check (await party2.receiveReceiverMessages(party1)) == messages
