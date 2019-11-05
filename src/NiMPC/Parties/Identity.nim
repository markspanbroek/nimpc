import strutils
import sequtils
import hashes
import sysrandom
import monocypher

type
  Identity* = object
    secret: Key
    public: Key
    identifier: string

proc initIdentity*(secret: Key = getRandomBytes(sizeof(Key))): Identity =
  result.secret = secret
  result.public = crypto_sign_public_key(result.secret)
  result.identifier = cast[string](result.public.toSeq()).toHex()

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
