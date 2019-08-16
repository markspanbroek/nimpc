import asyncdispatch
import sequtils
import LocalRandom
import Communication
import SecretSharing/Internals

export Secret

proc disclose*(secret: Secret, recipient: Party) {.async.} =
  let party = secret.party
  await party.send(recipient, await secret.share)

proc disclose*(secret: Secret) {.async.} =
  let party = secret.party
  for recipient in party.peers:
    await secret.disclose(recipient)

proc sum(shares: seq[Share]): uint64 =
  result = shares.foldl(a + b)

proc open*(secret: Secret): Future[uint32] {.async.} =
  result = uint32(await secret.openSumOfShares())

proc reveal*(secret: Secret): Future[uint32] {.async.} =
  await secret.disclose()
  result = await secret.open()

proc shareWithPeers(party: Party, input: uint32): Future[Share] {.async.} =
  var shares = @[random[Share]()]
  for receiver in party.peers:
    shares.add random[Share]()
    await party.send(receiver, shares[^1])
  result = shares[0] - sum(shares) + input

proc share*(party: Party, input: uint32): Secret =
  result = Secret(party: party, share: shareWithPeers(party, input))

proc obtain*(party: Party, sender: Party): Secret =
  result = Secret(party: party, share: party.receiveUint64(sender))
