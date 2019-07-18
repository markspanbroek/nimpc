import asyncdispatch
import sequtils
import sysrandom
import Communication

type Secret* = object
  party*: Party
  share*: uint32

method random*(party: Party): Future[Secret] {.async,base.} =
  result = Secret(party: party, share: getRandom())

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

proc open(shares: seq[uint32]): uint32 =
  result = shares.foldl(a + b)

method open*(secret: Secret): Future[uint32] {.async,base.} =
  let party = secret.party
  var shares = @[secret.share]
  for sender in party.peers:
    shares.add(await party.receive(sender))
  result = open(shares)

method open*(secret: Future[Secret]): Future[uint32] {.async,base.} =
  result = await open(await secret)

method share*(party: Party, input: uint32): Future[Secret] {.async,base.} =
  var shares = @[getRandom()]
  for receiver in party.peers:
    shares.add getRandom()
    await party.send(receiver, shares[^1])
  let share = shares[0] - open(shares) + input
  result = Secret(party: party, share: share)

method obtain*(party: Party, sender: Party): Future[Secret] {.async,base.} =
  let share = await party.receive(sender)
  result = Secret(party: party, share: share)
