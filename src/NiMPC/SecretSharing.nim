import asyncdispatch
import sequtils
import Random
import Communication

type Secret* = object
  party*: Party
  share*: uint64

method random*(party: Party): Future[Secret] {.async,base.} =
  result = Secret(party: party, share: random[uint64]())

method reveal*(secret: Secret, recipient: Party) {.async,base.} =
  let party = secret.party
  await party.send(recipient, secret.share)

proc reveal*(secret: Future[Secret], recipient: Party) {.async.} =
  await reveal(await secret, recipient)

proc reveal*(secret: Secret) {.async.} =
  let party = secret.party
  for recipient in party.peers:
    await secret.reveal(recipient)

proc reveal*(secret: Future[Secret]) {.async.} =
  await reveal(await secret)

proc open(shares: seq[uint64]): uint64 =
  result = shares.foldl(a + b)

method open*(secret: Secret): Future[uint32] {.async,base.} =
  let party = secret.party
  var shares = @[secret.share]
  for sender in party.peers:
    shares.add(await party.receiveUint64(sender))
  result = uint32(open(shares))

method open*(secret: Future[Secret]): Future[uint32] {.async,base.} =
  result = await open(await secret)

method share*(party: Party, input: uint32): Future[Secret] {.async,base.} =
  var shares = @[random[uint64]()]
  for receiver in party.peers:
    shares.add random[uint64]()
    await party.send(receiver, shares[^1])
  let share = shares[0] - open(shares) + input
  result = Secret(party: party, share: share)

method obtain*(party: Party, sender: Party): Future[Secret] {.async,base.} =
  let share = await party.receiveUint64(sender)
  result = Secret(party: party, share: share)
