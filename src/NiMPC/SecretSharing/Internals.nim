import asyncdispatch
import math
import ../Parties
import ../Communication

type
  Share* = uint64
  Secret* = object
    party*: Party
    share*: Future[Share]

proc openRawShare*(secret: Secret): Future[Share] {.async.} =
  let party = secret.party
  var shares = @[await secret.share]
  for sender in party.peers:
    shares.add(await party.receiveUint64(sender))
  result = sum(shares)
