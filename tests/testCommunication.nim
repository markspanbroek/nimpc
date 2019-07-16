import unittest
import bigints
import asyncdispatch
import NiMPC

suite "communication":
  var party1: Party
  var party2: Party

  setup:
    party1 = Party()
    party2 = Party()

  test "can send from one party to another":
    waitFor party1.send(party2, 42)

  test "can receive values for other party":
    waitFor party1.send(party2, 42)
    check (waitFor party2.receive(party1)) == 42

  test "value is received by recipient only":
    waitFor party1.send(party2, 42)
    check waitFor(party1.receive(party2)) != 42

  test "value is received from specified sender only":
    waitFor party1.send(party1, 42)
    check (waitFor party1.receive(party2)) != 42

  test "value is received only once":
    waitFor party1.send(party2, 42)
    discard waitFor party2.receive(party1)
    check (waitFor party2.receive(party1)) != 42
