import simpleot
import sequtils
import asyncdispatch
import NiMPC/Communication
export simpleot

type
  Senders = openArray[Sender]
  Receivers = openArray[Receiver]
  SenderMessages = openArray[SenderMessage]
  ReceiverMessages = openArray[ReceiverMessage]

proc generateSecrets*(senders: Senders): seq[SenderMessage] =
  result = senders.mapIt(it.generateSecret())

proc generateSecrets*(receivers: Receivers, 
                      senderMessages: SenderMessages): 
                      tuple[bits: seq[bool], messages: seq[ReceiverMessage]] =
  assert receivers.len == senderMessages.len
  for i in 0..<receivers.len:
    let (bits, message) = receivers[i].generateSecret(senderMessages[i])
    result.bits &= bits.mapIt(bool(it))
    result.messages &= message

proc generateKeys*(senders: Senders, 
                   receiverMessages: ReceiverMessages): (seq[Key], seq[Key]) =
  assert senders.len == receiverMessages.len
  for i in 0..<senders.len:
    let (keys0, keys1) = senders[i].generateKeys(receiverMessages[i])
    result[0] &= keys0
    result[1] &= keys1

proc generateKeys*(receivers: Receivers): seq[Key] =
  for receiver in receivers:
    result &= receiver.generateKeys()

proc receiveSenderMessages*(recipient: Party, sender: Party): 
                            Future[seq[SenderMessage]] {.async.} =
  result = await receive[seq[SenderMessage]](recipient, sender)

proc receiveReceiverMessages*(recipient: Party, sender: Party): 
                              Future[seq[ReceiverMessage]] {.async.} =
  result = await receive[seq[ReceiverMessage]](recipient, sender)
