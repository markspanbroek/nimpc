import asyncdispatch
import Parties
import SecretSharing
import SecretSharing/Internals
import Triples
import Triples/Math

proc `+`(a: Future[Share], b: Future[Share]): Future[Share] {.async.} =
  result = (await a) + (await b)

proc `+`(a: Future[Share], b: uint32): Future[Share] {.async.} =
  result = (await a) + b

proc `+`*(a: Secret, b: Secret): Secret =
  assert a.party == b.party
  result = Secret(party: a.party, share: a.share + b.share)

proc `+`*(a: Secret, b: uint32): Secret =
  if a.party.isFirst:
    result = Secret(party: a.party, share: a.share + b)
  else:
    result = a

proc `+`*(a: uint32, b: Secret): Secret =
  result = b + a

proc `-`(a: Future[Share], b: Future[Share]): Future[Share] {.async.} =
  result = (await a) - (await b)

proc `-`(a: Future[Share], b: uint32): Future[Share] {.async.} =
  result = (await a) - b

proc `-`(a: uint32, b: Future[Share]): Future[Share] {.async.} =
  result = Share(a) - (await b)

proc `-`(a: Future[Share]): Future[Share] {.async.} =
  result = 0'u64-(await a)

proc `-`*(a: Secret, b: Secret): Secret =
  assert a.party == b.party
  result = Secret(party: a.party, share: a.share - b.share)

proc `-`*(a: Secret, b: uint32): Secret =
  if a.party.isFirst:
    result = Secret(party: a.party, share: a.share - b)
  else:
    result = a
  
proc `-`*(a: uint32, b: Secret): Secret =
  if b.party.isFirst:
    result = Secret(party: b.party, share: a - b.share)
  else:
    result = b

proc `*`(a: Future[Share], b: uint32): Future[Share] {.async.} =
  result = (await a) * b

proc `*`*(a: Secret, b: uint32): Secret =
  result = Secret(party: a.party, share: a.share * b)

proc `*`*(a: uint32, b: Secret): Secret =
  result = b * a

proc evaluate(secret: Secret): Future[void] {.async.} =
  discard await secret.share

proc multiply(a: Secret, b: Secret): Future[Secret] {.async.} =
  await evaluate(a)
  await evaluate(b)

  let triple = await a.party.triple()

  let closedEpsilon = a - triple.a
  let closedDelta = b - triple.b

  await closedEpsilon.reveal()
  let epsilon = await closedEpsilon.openSumOfShares()
  await closedDelta.reveal()
  let delta = await closedDelta.openSumOfShares()

  result = 
    triple.c + (epsilon * triple.b) + (delta * triple.a) + (epsilon * delta)

proc toShare(secret: Future[Secret]): Future[Share] {.async.} =
  result = await (await secret).share

proc `*`*(a: Secret, b: Secret): Secret =
  assert a.party == b.party
  result = Secret(party: a.party, share: multiply(a, b).toShare())

