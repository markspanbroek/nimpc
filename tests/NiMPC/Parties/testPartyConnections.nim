import unittest
import sequtils
import math
import NiMPC/Parties/Local
import NiMPC/Parties/Connections

suite "Party connections":

  test "connects parties":
    let party1, party2, party3 = newLocalParty()
    connect(party1, party2, party3)
    check party1.peers == @[Party(party2), Party(party3)]
    check party2.peers == @[Party(party1), Party(party3)]
    check party3.peers == @[Party(party1), Party(party2)]

  test "only one party is the first party":
    let parties = newSeqWith(3, newLocalParty())
    connect(parties)
    let firsts = parties.mapIt(int(it.isFirst)).sum()
    check firsts == 1
