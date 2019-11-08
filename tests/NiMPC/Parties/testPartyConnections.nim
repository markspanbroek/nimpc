import unittest
import sequtils
import math
import examples/Identity
import NiMPC/Parties/Local
import NiMPC/Parties/Remote
import NiMPC/Parties/Connections

suite "Party connections":

  test "connects parties":
    let party1, party2, party3 = newLocalParty()
    connect(party1, party2, party3)
    check party1.peers == @[Party(party2), Party(party3)]
    check party2.peers == @[Party(party1), Party(party3)]
    check party3.peers == @[Party(party1), Party(party2)]

  test "connects different types of parties":
    let local = newLocalParty()
    let remote = newRemoteParty(exampleIdentity())
    connect(local, remote)

  test "connects sequence of parties":
    connect newSeqWith(3, newLocalParty())

  test "only one party is the first party":
    let parties = newSeqWith(3, newLocalParty())
    connect(parties)
    let firsts = parties.mapIt(int(it.isFirst)).sum()
    check firsts == 1
