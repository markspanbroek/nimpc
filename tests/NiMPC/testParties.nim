import unittest
import sequtils
import math
import NiMPC/Parties

suite "parties":

  test "can create a party":
    check Party() != nil

  test "connects parties":
    let party1, party2, party3 = Party()
    connect(party1, party2, party3)
    check party1.peers == @[party2, party3]
    check party2.peers == @[party1, party3]
    check party3.peers == @[party1, party2]

  test "only one party is the first party":
    let parties = newSeqWith(3, Party())
    connect(parties)
    let firsts = parties.mapIt(int(it.isFirst)).sum()
    check firsts == 1
