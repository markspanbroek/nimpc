import unittest
import NiMPC

test "can create a party":
  check Party() != nil

test "can send from one party to another":
  let party1 = Party()
  let party2 = Party()
  let value = 42 # TODO: bigint
  party1.send(party2, value)
