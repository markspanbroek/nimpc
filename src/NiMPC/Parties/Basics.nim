import hashes
import strformat
import sequtils
import asyncdispatch

type Party* = ref object of RootObj
  peers*: seq[Party]

proc connect*(parties: varargs[Party]) =
  for party1 in parties:
    for party2 in parties:
      if party1 != party2:
        party1.peers.add(party2)

method acceptDelivery*(receiver: Party,
                       sender: Party,
                       messsage: string) {.async,base.} =
  assert(false, "base method called, should be overridden")

method id*(party: Party): ByteAddress {.base.} =
  cast[ByteAddress](unsafeAddr party[])

method hash*(party: Party): Hash {.base.} =
  hash(party.id)

method `$`*(party: Party): string {.base.} =
  fmt"party{party.id}"

proc isFirst*(party: Party): bool =
  result = party.peers.allIt(party < it)
