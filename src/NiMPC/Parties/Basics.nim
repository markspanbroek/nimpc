import hashes
import strformat
import asyncdispatch
import Identity
export Identity

type
  Party* = ref object of RootObj
    peers*: seq[Party]
    id*: Identity

proc init*(party: Party) =
  party.id = initIdentity()

proc destroyParty*(party: Party) =
  destroyIdentity(party.id)

proc destroyParties*(parties: varargs[Party]) =
  for party in parties:
    destroyParty(party)

method acceptDelivery*(receiver: Party,
                       sender: Party,
                       messsage: string) {.async,base.} =
  assert(false, "base method called, should be overridden")

proc `==`*(a, b: Party): bool =
  not isNil(b) and a.id == b.id

proc `<`*(a, b: Party): bool =
  a.id < b.id

method hash*(party: Party): Hash {.base.} =
  hash(party.id)

method `$`*(party: Party): string {.base.} =
  fmt"party{party.id}"
