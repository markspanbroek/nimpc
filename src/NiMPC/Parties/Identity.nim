import strutils
import sequtils
import hashes
import monocypher

type
  Identity* = object
    publicKey*: Key
    identifier: string

proc initIdentity*(publicKey: Key): Identity =
  result.publicKey = publicKey
  result.identifier = cast[string](result.publicKey.toSeq()).toHex()

proc `$`*(identity: Identity): string =
  return identity.identifier

proc `==`*(a, b: Identity): bool =
  a.identifier == b.identifier

proc `<`*(a, b: Identity): bool =
  a.identifier < b.identifier

proc `<=`*(a, b: Identity): bool =
  a.identifier <= b.identifier

proc `hash`*(identity: Identity): Hash =
  hash(identity.identifier)
