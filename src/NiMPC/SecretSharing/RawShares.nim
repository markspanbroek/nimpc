import asyncdispatch
import ../Parties
import ../SecretSharing
import Internals

export Share
export openRawShare

proc toFuture(share: Share): Future[Share] {.async.} =
  result = share

proc rawShare*(party: Party, share: Share): Secret =
  result.party = party
  result.share = share.toFuture()

proc revealRawShare*(secret: Secret): Future[Share] {.async.} =
  await secret.disclose()
  result = await secret.openRawShare()
