import strutils
import sequtils
import hashes
import monocypher

type
  Identity* = distinct Key

proc initIdentity*(publicKey: Key): Identity =
  Identity(publicKey)

proc publicKey*(identity: Identity): Key =
  Key(identity)

proc `$`*(identity: Identity): string =
  let publicKey = identity.publicKey
  cast[string](publicKey.toSeq()).toHex()

proc fromStringBytes[T](s: string): T =
  if s.len != sizeof(result):
    raise newException(ValueError, "could not convert, invalid string length")
  copyMem(addr result, unsafeAddr(s[0]), sizeof(result))

proc parseIdentity*(s: string): Identity =
  let bytes = parseHexStr(s)
  let publicKey = fromStringBytes[Key](bytes)
  result = initIdentity(publicKey)

proc `==`*(a, b: Identity): bool =
  $a == $b

proc `<`*(a, b: Identity): bool =
  $a < $b

proc `<=`*(a, b: Identity): bool =
  $a <= $b

proc `hash`*(identity: Identity): Hash =
  hash($identity)
