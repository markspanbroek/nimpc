import hashes
import strformat
import sequtils
import asyncdispatch
import Identity

type
  Party* = ref object of RootObj
    peers*: seq[Party]
    id*: Identity

proc init*(party: Party) =
  party.id = initIdentity()

proc newParty*: Party =
  new(result)
  init(result)

proc destroyParty*(party: Party) =
  destroyIdentity(party.id)

proc destroyParties*(parties: varargs[Party]) =
  for party in parties:
    destroyParty(party)

proc `==`*(a, b: Party): bool =
  not isNil(b) and a.id == b.id

proc `<`*(a, b: Party): bool =
  a.id < b.id

method acceptDelivery*(receiver: Party,
                       sender: Party,
                       messsage: string) {.async,base.} =
  assert(false, "base method called, should be overridden")

proc connect*(parties: varargs[Party]) =
  for party1 in parties:
    for party2 in parties:
      if party1 != party2:
        party1.peers.add(party2)

method hash*(party: Party): Hash {.base.} =
  hash(party.id)

method `$`*(party: Party): string {.base.} =
  fmt"party{party.id}"

proc isFirst*(party: Party): bool =
  result = party.peers.allIt(party < it)
