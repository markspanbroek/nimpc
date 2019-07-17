import unittest
import NiMPC

test "can create a party":
  check Party() != nil

test "connects parties":
  let party1 = Party()
  let party2 = Party()
  let party3 = Party()
  connect(party1, party2, party3)
  check party1.peers == @[party2, party3]
  check party2.peers == @[party1, party3]
  check party3.peers == @[party1, party2]
