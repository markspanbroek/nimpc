import asyncdispatch
import math
import ../Parties
import ../Communication

type 
  Share* = uint64
  Secret* = object
    party*: Party
    share*: Share

method openSumOfShares*(secret: Secret): Future[Share] {.async,base.} =
  let party = secret.party
  var shares = @[secret.share]
  for sender in party.peers:
    shares.add(await party.receiveUint64(sender))
  result = sum(shares)
