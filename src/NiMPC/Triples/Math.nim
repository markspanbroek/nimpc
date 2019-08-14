import asyncdispatch
import ../SecretSharing/Internals
import ../Parties

proc `*`*[T](a: bool, b: T): T =
  if a:
    result = b
  else:
    result = 0

proc `*`*[T](a: openArray[bool], b: T): seq[T] =
  for element in a:
    result &= element * b

proc `+`*[T](a: openArray[T], b: openArray[T]): seq[T] =
  assert a.len == b.len
  for i in 0..<a.len:
    result &= a[i] + b[i]

proc `-`*[T](a: openArray[T]): seq[T] =
  for element in a:
    result &= T(0) - element

proc `*`(a: Share, b: Future[Share]): Future[Share] {.async.} =
  result = a * (await b)

proc `*`*(a: Share, b: Secret): Secret =
  result = Secret(party: b.party, share: a * b.share)

proc `+`(a: Future[Share], b: Share): Future[Share] {.async.} =
  result = (await a) + b

proc `+`*(a: Secret, b: Share): Secret =
  if a.party.isFirst:
    result = Secret(party: a.party, share: a.share + b)
  else:
    result = a

