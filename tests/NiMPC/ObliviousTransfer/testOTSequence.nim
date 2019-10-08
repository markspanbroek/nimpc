import unittest
import sequtils
import NiMPC/ObliviousTransfer/Sequence

suite "sequence of oblivious transfers":

  var senders: seq[Sender]
  var receivers: seq[Receiver]

  setUp:
    senders = @[Sender(), Sender()]
    receivers = @[Receiver(), Receiver()]

  test "generates secrets for a sequence of senders":
    let messages = senders.generateSecrets()
    var empty: SenderMessage
    check messages.len == 2
    check messages != @[empty, empty]

  test "generates random choice bits":
    var bits1, bits2 = generateChoiceBits(1024)
    check bits1 != bits2

  test "generates secrets for a sequence of receivers":
    let senderMessages = senders.generateSecrets()
    let bits = generateChoiceBits(uint(receivers.len * 4))
    let receiverMessages = receivers.generateSecrets(senderMessages, bits)
    var empty: ReceiverMessage
    check receiverMessages.len == 2
    check receiverMessages != @[empty, empty]

  test "raises error when given incorrect number of sender messages":
    let bits = generateChoiceBits(uint(receivers.len * 4))
    var senderMessages = senders.generateSecrets()
    senderMessages = senderMessages.cycle(2)
    expect Exception:
      discard receivers.generateSecrets(senderMessages, bits)

  test "raises error when given incorrect number of choice bits":
    let bits = generateChoiceBits(uint((receivers.len + 1) * 4))
    var senderMessages = senders.generateSecrets()
    expect Exception:
      discard receivers.generateSecrets(senderMessages, bits)

  test "generates keys for a sequence of senders":
    let senderMessages = senders.generateSecrets()
    let bits = generateChoiceBits(uint(receivers.len * 4))
    let receiverMessages = receivers.generateSecrets(senderMessages, bits)
    let (keys0, keys1) = senders.generateKeys(receiverMessages)
    var empty: Key
    check keys0.len == 8
    check keys1.len == 8
    check keys0 != repeat(empty, 8)
    check keys1 != repeat(empty, 8)

  test "raises error when given incorrect number of receiver messages":
    let senderMessages = senders.generateSecrets()
    let bits = generateChoiceBits(uint(receivers.len * 4))
    var receiverMessages = receivers.generateSecrets(senderMessages, bits)
    receiverMessages = receiverMessages.cycle(2)
    expect Exception:
      discard senders.generateKeys(receiverMessages)

  test "generates keys for a sequence of receivers":
    let senderMessages = senders.generateSecrets()
    let bits = generateChoiceBits(uint(receivers.len * 4))
    discard receivers.generateSecrets(senderMessages, bits)
    let keys = receivers.generateKeys()
    var empty: Key
    check keys.len == 8
    check keys != repeat(empty, 8)
