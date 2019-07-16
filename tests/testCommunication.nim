import unittest
import bigints
import NiMPC

test "can create a party":
  check Party() != nil

test "can send from one party to another":
  let party1 = Party()
  let party2 = Party()
  let value: BigInt = 42
  party1.send(party2, value)

test "can receive values for other parties":
  let party1 = Party()
  let party2 = Party()
  let value: BigInt = 42
  party1.send(party2, value)
  check party2.receive(party1) == value

test "value is received by recipient only":
  let party1 = Party()
  let party2 = Party()
  let value: BigInt = 42
  party1.send(party2, value)
  check party1.receive(party2) != value
