import asyncdispatch
import LocalRandom
import Parties
import SecretSharing
import SecretSharing/RawShares

proc random*(party: LocalParty): Secret =
  result = party.rawShare(random[Share]())

proc openRandom*(party: LocalParty): Future[uint32] {.async.} =
  let closed = party.random()
  await closed.disclose()
  result = await closed.open()
