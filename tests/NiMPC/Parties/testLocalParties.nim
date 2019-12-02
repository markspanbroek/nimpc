import unittest
import monocypher
import NiMPC/Parties/Local

suite "local parties":

  test "can be created":
    check newLocalParty() != nil

  test "wipe their secret key when destroyed":
    var secretKeyPtr: ptr Key
    block:
      let party = newLocalParty()
      defer: party.destroy()
      secretKeyPtr = addr party.secretKey
    var empty: Key
    check secretKeyPtr[] == empty
