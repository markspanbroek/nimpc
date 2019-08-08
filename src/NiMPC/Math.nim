import asyncdispatch
import Parties
import SecretSharing
import Triples

proc `+`(a: Secret, b: Secret): Secret =
  assert a.party == b.party
  result = Secret(party: a.party, share: a.share + b.share)

proc `+`(a: Secret, b: uint32): Secret =
  if a.party.isFirst:
    result = Secret(party: a.party, share: a.share + b)
  else:
    result = a
  
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
  if a.party.isFirst:
    result = Secret(party: a.party, share: a.share - b)
  else:
    result = a
  
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

converter toFuture(secret: Secret): Future[Secret] =
  result = newFuture[Secret]()
  result.complete(secret)

proc `*`(a: Secret, b: Secret): Future[Secret] {.async.} =
  assert a.party == b.party
  let triple = await a.party.triple()

  let closedEpsilon = a - triple.a
  let closedDelta = b - triple.b

  await closedEpsilon.reveal()
  await closedDelta.reveal()

  let epsilon = await closedEpsilon.open()
  let delta = await closedDelta.open()

  result = 
    await triple.c + epsilon * triple.b + delta * triple.a + epsilon * delta

proc `*`*(a: Future[Secret], b: Future[Secret]): Future[Secret] {.async.} =
  result = await ((await a) * (await b))
