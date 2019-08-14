import asyncdispatch
import sequtils
import LocalRandom
import Communication
import SecretSharing/Internals

export Secret

method reveal*(secret: Secret, recipient: Party) {.async,base.} =
  let party = secret.party
  await party.send(recipient, await secret.share)

proc reveal*(secret: Secret) {.async.} =
  let party = secret.party
  for recipient in party.peers:
    await secret.reveal(recipient)

proc sum(shares: seq[Share]): uint64 =
  result = shares.foldl(a + b)

method open*(secret: Secret): Future[uint32] {.async,base.} =
  result = uint32(await secret.openSumOfShares())

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
