import Basics
import sequtils
import asyncdispatch

proc connect*(parties: varargs[Party]) =
  for party1 in parties:
    for party2 in parties:
      if party1 != party2:
        party1.peers.add(party2)

proc isFirst*(party: Party): bool =
  result = party.peers.allIt(party < it)
