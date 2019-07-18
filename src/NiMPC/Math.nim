import asyncdispatch
import SecretSharing

proc `+`*(a: Secret, b: Secret): Secret =
  assert a.party == b.party
  result = Secret(party: a.party, share: a.share + b.share)

proc `+`*(a: Future[Secret], b: Future[Secret]): Future[Secret] {.async.} =
  result = (await a) + (await b)
