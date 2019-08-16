import asyncdispatch
import sequtils
import LocalRandom
import Communication
import SecretSharing/Internals

export Secret

method disclose*(secret: Secret, recipient: Party) {.async,base.} =
  let party = secret.party
  await party.send(recipient, await secret.share)

proc disclose*(secret: Secret) {.async.} =
  let party = secret.party
  for recipient in party.peers:
    await secret.disclose(recipient)

proc sum(shares: seq[Share]): uint64 =
  result = shares.foldl(a + b)

method open*(secret: Secret): Future[uint32] {.async,base.} =
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

method share*(party: Party, input: uint32): Secret {.base.} =
  result = Secret(party: party, share: shareWithPeers(party, input))

method obtain*(party: Party, sender: Party): Secret {.base.} =
  result = Secret(party: party, share: party.receiveUint64(sender))
