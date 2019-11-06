import unittest
import monocypher
import NiMPC/Parties/Local

suite "local parties":

  test "can create a party":
    check newLocalParty() != nil

  test "it wipes the secret key when destroyed":
    var secretKeyPtr: ptr Key
    block:
      let party = newLocalParty()
      defer: party.destroy()
      secretKeyPtr = addr party.secretKey
    var empty: Key
    check secretKeyPtr[] == empty
