import asyncdispatch
import sequtils
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

proc sendOT*(sender: LocalParty, recipient: Party, amount:uint=4):
             Future[SendResult] {.async.} =
  assert amount mod 4 == 0
  let otSenders = newSeqWith(int(amount div 4), Sender())
  let senderMessages = otSenders.generateSecrets()
  await sender.send(recipient, senderMessages)
  let receiverMessages = await sender.receiveReceiverMessages(recipient)
  result = otSenders.generateKeys(receiverMessages)

proc receiveOT*(recipient: LocalParty, sender: Party, choiceBits: ChoiceBits):
                Future[ReceiveResult] {.async.} =
  let amount = uint(choiceBits.len)
  assert amount mod 4 == 0
  let otReceivers = newSeqWith(int(amount div 4), Receiver())
  let senderMessages = await recipient.receiveSenderMessages(sender)
  let receiverMessages = otReceivers.generateSecrets(senderMessages, choiceBits)
  await recipient.send(sender, receiverMessages)
  result = otReceivers.generateKeys()
