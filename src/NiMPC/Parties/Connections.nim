import Basics
import sequtils

proc connectImpl(parties: varargs[Party]) =
  for party1 in parties:
    for party2 in parties:
      if party1 != party2:
        party1.peers.add(party2)

proc connect*(parties: varargs[Party]) =
  connectImpl(parties)

proc connect*[T: Party](parties: varargs[T]) =
  connectImpl(parties.mapIt(Party(it)))

proc isFirst*[T: Party](party: T): bool =
  party.peers.allIt(party < it)
