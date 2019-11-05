import hashes
import strformat
import strutils
import sequtils
import asyncdispatch
import sysrandom
import monocypher

type
  Party* = ref object of RootObj
    peers*: seq[Party]
    secret: Key
    public: Key
    initialized: bool

method acceptDelivery*(receiver: Party,
                       sender: Party,
                       messsage: string) {.async,base.} =
  assert(false, "base method called, should be overridden")

method id*(party: Party): string {.base.} =
  if not party.initialized:
    party.secret = getRandomBytes(sizeof(Key))
    party.public = crypto_sign_public_key(party.secret)
    party.initialized = true
  result = cast[string](party.public.toSeq()).toHex()

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
