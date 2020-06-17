import strutils
import hashes
import monocypher
import HexString

type
  Identity* = distinct Key

proc initIdentity*(publicKey: Key): Identity =
  Identity(publicKey)

proc publicKey*(identity: Identity): Key =
  Key(identity)

proc `$`*(identity: Identity): string =
  hex(identity.publicKey)

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

proc `hash`*(identity: Identity): hashes.Hash =
  hash($identity)
