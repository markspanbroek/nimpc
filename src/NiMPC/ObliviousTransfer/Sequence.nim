import simpleot
import sequtils

export Sender, Receiver, SenderMessage, ReceiverMessage, Key

type
  Senders* = openArray[Sender]
  Receivers* = openArray[Receiver]
  SenderMessages* = openArray[SenderMessage]
  ReceiverMessages* = openArray[ReceiverMessage]

proc generateSecrets*(senders: Senders): seq[SenderMessage] =
  result = senders.mapIt(it.generateSecret())

proc generateChoiceBits*(amount:uint=4): seq[bool] =
  assert amount mod 4 == 0
  while result.len < int(amount):
    result &= simpleot.generateChoiceBits().mapIt(bool(it))

proc generateSecrets*(receivers: Receivers,
                      senderMessages: SenderMessages,
                      choiceBits: seq[bool]):
                      seq[ReceiverMessage] =
  assert senderMessages.len == receivers.len
  assert choiceBits.len == receivers.len * 4
  for i in 0..<receivers.len:
    var bits: ChoiceBits
    for j in 0..<4:
      bits[j] = cuchar(choiceBits[i*4+j])
    let message = receivers[i].generateSecret(senderMessages[i], bits)
    result &= message

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
