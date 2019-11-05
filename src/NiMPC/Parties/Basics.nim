import hashes
import strformat
import strutils
import sequtils
import asyncdispatch
import sysrandom
import monocypher

type
  Identity = object
    secret: Key
    public: Key
    identifier: string
    initialized: bool
  Party* = ref object of RootObj
    peers*: seq[Party]
    identity: Identity

proc `$`(identity: var Identity): string =
  if not identity.initialized:
    identity.secret = getRandomBytes(sizeof(Key))
    identity.public = crypto_sign_public_key(identity.secret)
    identity.identifier = cast[string](identity.public.toSeq()).toHex()
    identity.initialized = true
  return identity.identifier

method acceptDelivery*(receiver: Party,
                       sender: Party,
                       messsage: string) {.async,base.} =
  assert(false, "base method called, should be overridden")

method id*(party: Party): string {.base.} =
  result = $party.identity

proc connect*(parties: varargs[Party]) =
  for party1 in parties:
    for party2 in parties:
      if party1.id != party2.id:
        party1.peers.add(party2)

method hash*(party: Party): Hash {.base.} =
  hash(party.id)

method `$`*(party: Party): string {.base.} =
  fmt"party{party.id}"

proc isFirst*(party: Party): bool =
  result = party.peers.allIt(party.id < it.id)
