import unittest
import NiMPC/Parties/Local

suite "local parties":

  test "can create a party":
    check newLocalParty() != nil

