import unittest
import bigints
import NiMPC

suite "communication":
  var party1: Party
  var party2: Party

  setup:
    party1 = Party()
    party2 = Party()

  test "can send from one party to another":
    party1.send(party2, 42)

  test "can receive values for other party":
    party1.send(party2, 42)
    check party2.receive(party1) == 42

  test "value is received by recipient only":
    party1.send(party2, 42)
    check party1.receive(party2) != 42

# value is only recieved from specified sender
