import unittest
import sequtils
import math
import monocypher
import NiMPC/Parties/Basics

suite "parties":

  test "can create a party":
    check newParty() != nil

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

  test "after destroying a party, its secret key is wiped":
    let party = newParty()
    destroyParty(party)
    var empty: Key
    check party.id.secretKey == empty

  test "multiple parties can be destroyed at once":
    let party1, party2 = newParty()
    destroyParties(party1, party2)
    var empty: Key
    check party1.id.secretKey == empty
    check party2.id.secretKey == empty
