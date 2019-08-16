import asyncdispatch
import LocalRandom
import Parties
import SecretSharing
import SecretSharing/Internals

method random*(party: Party): Secret {.base.} =
  result = party.rawShare(random[Share]())

method openRandom*(party: Party): Future[uint32] {.async,base.} =
  let closed = party.random()
  await closed.disclose()
  result = await closed.open()
