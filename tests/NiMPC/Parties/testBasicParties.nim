import unittest
import sequtils
import monocypher
import NiMPC/Parties/Local

suite "local parties":

  test "can create a party":
    check newLocalParty() != nil

  test "after destroying a party, its secret key is wiped":
    let party = newLocalParty()
    destroyParty(party)
    var empty: Key
    check party.id.secretKey == empty

  test "multiple parties can be destroyed at once":
    let parties = newSeqWith(10, newLocalParty())
    destroyParties(parties)
    var empty: Key
    check parties.allIt(it.id.secretKey == empty)
