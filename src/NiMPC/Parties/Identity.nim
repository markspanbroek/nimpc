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

proc `==`*(a, b: Identity): bool =
  $a == $b

proc `<`*(a, b: Identity): bool =
  $a < $b

proc `<=`*(a, b: Identity): bool =
  $a <= $b

proc `hash`*(identity: Identity): Hash =
  hash($identity)
