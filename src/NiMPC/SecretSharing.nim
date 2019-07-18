import asyncdispatch
import sequtils
import sysrandom
import Communication

type Secret* = object
  share*: uint32

proc random*: Secret =
  result = Secret(share: getRandom())

method reveal*(party: Party, secret: Secret, recipient: Party) {.async,base.} =
  await party.send(recipient, secret.share)

proc open(shares: seq[uint32]): uint32 =
  result = shares.foldl(a + b)

method open*(party: Party, secret: Secret): Future[uint32] {.async,base.} =
  var shares = @[secret.share]
  for sender in party.peers:
    shares.add(await party.receive(sender))
  result = open(shares)

method share*(party: Party, input: uint32): Future[Secret] {.async,base.} =
  var shares = @[getRandom()]
  for receiver in party.peers:
    shares.add getRandom()
    await party.send(receiver, shares[^1])
  result = Secret(share: shares[0] - open(shares) + input)

method obtain*(party: Party, sender: Party): Future[Secret] {.async,base.} =
  result = Secret(share: await party.receive(sender))
