import hashes
import strformat
import sequtils

type Party* = ref object
  peers*: seq[Party]

proc connect*(parties: varargs[Party]) =
  for party1 in parties:
    for party2 in parties:
      if party1 != party2:
        party1.peers.add(party2)

proc id(party: Party): ByteAddress =
  cast[ByteAddress](unsafeAddr party[])

proc hash*(party: Party): Hash =
  hash(party.id)

proc `$`*(party: Party): string =
  fmt"party{party.id}"

proc isFirst*(party: Party): bool =
  result = party.peers.allIt(party < it)
