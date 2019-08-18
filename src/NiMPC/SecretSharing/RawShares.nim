import asyncdispatch
import Internals
import ../SecretSharing

export Share
export rawShare
export openRawShare

proc revealRawShare*(secret: Secret): Future[Share] {.async.} =
  await secret.disclose()
  result = await secret.openRawShare()
