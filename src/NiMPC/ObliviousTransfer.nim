import asyncdispatch
import sequtils
import algorithm
import Parties
import ObliviousTransfer/Sequence
import ObliviousTransfer/Communication

export Key

type
  Keys = seq[Key]
  ChoiceBits = seq[bool]
  SendResult = (Keys, Keys)
  ReceiveResult = tuple[bits: ChoiceBits, keys: Keys]

proc numberOfExchanges(numberOfOTs: uint): uint =
  # a single simpleot exchange results in 4 oblivious transfers
  result = (numberOfOTs + 3) div 4

proc truncate[T](sequence: openArray[T], amount: uint): seq[T] =
  result = sequence[0..<int(amount)]

proc truncate[T,U](pair: (seq[T], seq[U]), amount: uint): (seq[T], seq[U]) =
  result[0] = pair[0].truncate(amount)
  result[1] = pair[1].truncate(amount)

proc sendOT*(sender, receiver: Party, amount:uint=4):
             Future[SendResult] {.async.} =
  let otSenders = newSeqWith(int(numberOfExchanges(amount)), Sender())
  let senderMessages = otSenders.generateSecrets()
  await sender.send(receiver, senderMessages)
  let receiverMessages = await sender.receiveReceiverMessages(receiver)
  result = otSenders.generateKeys(receiverMessages)
  result = result.truncate(amount)

proc receiveOT*(receiver, sender: Party, amount:uint=4):
                Future[ReceiveResult] {.async.} =
  let otReceivers = newSeqWith(int(numberOfExchanges(amount)), Receiver())
  let senderMessages = await receiver.receiveSenderMessages(sender)
  let (bits, receiverMessages) = otReceivers.generateSecrets(senderMessages)
  await receiver.send(sender, receiverMessages)
  let keys = otReceivers.generateKeys()
  result = (bits, keys)
  result = result.truncate(amount)
