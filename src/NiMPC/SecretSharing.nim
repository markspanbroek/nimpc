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

method open*(party: Party, secret: Secret): Future[uint32] {.async,base.} =
  var shares = @[secret.share]
  for sender in party.peers:
    shares.add(await party.receive(sender))
  result = shares.foldl(a + b)

method share*(party: Party, input: uint32): Future[Secret] {.async,base.} =
  let numberOfParties = party.peers.len + 1
  let shares = newSeqWith(numberOfParties, getRandom())
  let r = shares.foldl(a + b)
  for i in 0..<party.peers.len:
    await party.send(party.peers[i], shares[i])
  result = Secret(share: shares[^1] - r + input)

method obtain*(party: Party, sender: Party): Future[Secret] {.async,base.} =
  result = Secret(share: await party.receive(sender))
