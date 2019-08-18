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

proc revealSumOfShares(secret: Secret): Future[Share] {.async.} =
  await secret.disclose()
  result = await secret.openSumOfShares()

proc multiply(x: Secret, y: Secret): Future[Secret] {.async.} =
  await evaluate(x)
  await evaluate(y)

  # Implementation of the multiplication protocol from the SPDZ2k paper:
  # https://eprint.iacr.org/2018/482.pdf, Figure 9

  let (a, b, c) = await x.party.triple()

  let ϵ = await (x - a).revealSumOfShares()
  let δ = await (y - b).revealSumOfShares()

  result = c + (ϵ * b) + (δ * a) + (ϵ * δ)

proc toShare(secret: Future[Secret]): Future[Share] {.async.} =
  result = await (await secret).share

proc `*`*(a: Secret, b: Secret): Secret =
  assert a.party == b.party
  result = Secret(party: a.party, share: multiply(a, b).toShare())

