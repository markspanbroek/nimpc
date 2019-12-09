import hashes
import strformat
import asyncdispatch
import Identity
import Envelopes
export Identity

type
  Party* = ref object of RootObj
    peers*: seq[Party]
    id*: Identity

proc init*(party: Party, id: Identity) =
  party.id = id

method acceptDelivery*(receiver: Party,
                       sender: Party,
                       messsage: SealedEnvelope) {.async,base.} =
  assert(false, "base method called, should be overridden")

proc `==`*(a, b: Party): bool =
  not isNil(b) and a.id == b.id

proc `<`*(a, b: Party): bool =
  a.id < b.id

method hash*(party: Party): Hash {.base.} =
  hash(party.id)

method `$`*(party: Party): string {.base.} =
  fmt"party{party.id}"

proc `[]`*(parties: seq[Party], id: Identity): Party =
  for party in parties:
    if party.id == id:
      return party
  raise newException(IndexError, fmt"no party with id {id} found")
