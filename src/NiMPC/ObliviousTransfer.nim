import asyncdispatch
import sequtils
import algorithm
import Parties
import ObliviousTransfer/Sequence
import ObliviousTransfer/Communication

export Sequence.Key
export Sequence.generateChoiceBits

type
  Keys = seq[Key]
  ChoiceBits = seq[bool]
  SendResult = (Keys, Keys)
  ReceiveResult = Keys

proc sendOT*(sender, receiver: Party, amount:uint=4):
             Future[SendResult] {.async.} =
  assert amount mod 4 == 0
  let otSenders = newSeqWith(int(amount div 4), Sender())
  let senderMessages = otSenders.generateSecrets()
  await sender.send(receiver, senderMessages)
  let receiverMessages = await sender.receiveReceiverMessages(receiver)
  result = otSenders.generateKeys(receiverMessages)

proc receiveOT*(receiver, sender: Party, choiceBits: ChoiceBits):
                Future[ReceiveResult] {.async.} =
  let amount = uint(choiceBits.len)
  assert amount mod 4 == 0
  let otReceivers = newSeqWith(int(amount div 4), Receiver())
  let senderMessages = await receiver.receiveSenderMessages(sender)
  let receiverMessages = otReceivers.generateSecrets(senderMessages, choiceBits)
  await receiver.send(sender, receiverMessages)
  result = otReceivers.generateKeys()
