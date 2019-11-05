import unittest
import sequtils
import math
import NiMPC/Parties/Basics
import NiMPC/Parties/Connections

suite "Party connections":

  test "connects parties":
    let party1, party2, party3 = newParty()
    connect(party1, party2, party3)
    check party1.peers == @[party2, party3]
    check party2.peers == @[party1, party3]
    check party3.peers == @[party1, party2]

  test "only one party is the first party":
    let parties = newSeqWith(3, newParty())
    connect(parties)
    let firsts = parties.mapIt(int(it.isFirst)).sum()
    check firsts == 1
