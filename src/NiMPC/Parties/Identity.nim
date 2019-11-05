import strutils
import sequtils
import sysrandom
import monocypher

type
  Identity* = object
    secret: Key
    public: Key
    identifier: string
    initialized: bool

proc `$`*(identity: var Identity): string =
  if not identity.initialized:
    identity.secret = getRandomBytes(sizeof(Key))
    identity.public = crypto_sign_public_key(identity.secret)
    identity.identifier = cast[string](identity.public.toSeq()).toHex()
    identity.initialized = true
  return identity.identifier
