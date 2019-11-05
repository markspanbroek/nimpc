import strutils
import sequtils
import hashes
import sysrandom
import monocypher

type
  Identity* = object
    secretKey*: Key
    publicKey*: Key
    identifier: string

proc initIdentity*(secretKey: Key = getRandomBytes(sizeof(Key))): Identity =
  result.secretKey = secretKey
  result.publicKey = crypto_sign_public_key(result.secretKey)
  result.identifier = cast[string](result.publicKey.toSeq()).toHex()

proc destroyIdentity*(identity: Identity) =
  crypto_wipe(identity.secretKey)

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
