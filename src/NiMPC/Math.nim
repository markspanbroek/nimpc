import asyncdispatch
import SecretSharing

proc `+`(a: Secret, b: Secret): Secret =
  assert a.party == b.party
  result = Secret(party: a.party, share: a.share + b.share)

proc `+`(a: Secret, b: uint32): Secret =
  result = Secret(party: a.party, share: a.share + b)
  
proc `+`*(a: Future[Secret], b: Future[Secret]): Future[Secret] {.async.} =
  result = (await a) + (await b)

proc `+`*(a: Future[Secret], b: uint32): Future[Secret] {.async.} =
  result = (await a) + b

proc `+`*(a: uint32, b: Future[Secret]): Future[Secret] {.async.} =
  result = await (b + a)

proc `-`(a: Secret, b: Secret): Secret =
  assert a.party == b.party
  result = Secret(party: a.party, share: a.share - b.share)

proc `-`(a: Secret, b: uint32): Secret =
  result = Secret(party: a.party, share: a.share - b)
  
proc `-`*(a: Future[Secret], b: Future[Secret]): Future[Secret] {.async.} =
  result = (await a) - (await b)

proc `-`*(a: Future[Secret], b: uint32): Future[Secret] {.async.} =
  result = (await a) - b

proc `-`*(a: uint32, b: Future[Secret]): Future[Secret] {.async.} =
  result = await (b - a)

proc `*`(a: Secret, b: uint32): Secret =
  result = Secret(party: a.party, share: a.share * b)
  
proc `*`*(a: Future[Secret], b: uint32): Future[Secret] {.async.} =
  result = (await a) * b

proc `*`*(a: uint32, b: Future[Secret]): Future[Secret] {.async.} =
  result = await (b * a)
