import Basics
import sequtils

proc connect*[T: Party](parties: varargs[T]) =
  for party1 in parties:
    for party2 in parties:
      if party1 != party2:
        party1.peers.add(party2)

proc isFirst*[T: Party](party: T): bool =
  party.peers.allIt(party < it)
