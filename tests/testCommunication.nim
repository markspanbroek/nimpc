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
    let future = party2.receive(party1)
    waitFor party1.send(party2, 42)
    check (waitFor future) == 42

  test "value is received by recipient only":
    let future = party1.receive(party2)
    waitFor party1.send(party2, 42)
    expect Exception:
      discard waitFor future

  test "value is received from specified sender only":
    let future = party1.receive(party2)
    waitFor party1.send(party1, 42)
    expect Exception:
      discard waitFor future
