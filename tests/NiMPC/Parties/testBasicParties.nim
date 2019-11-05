import unittest
import monocypher
import NiMPC/Parties/Basics

suite "parties":

  test "can create a party":
    check newParty() != nil

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
