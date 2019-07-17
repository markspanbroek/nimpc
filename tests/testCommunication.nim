import unittest
import bigints
import asynctest
import NiMPC

suite "communication":
  var party1, party2, party3: Party

  setup:
    party1 = Party()
    party2 = Party()
    party3 = Party()
    connect(party1, party2, party3)
    
  asynctest "can send from one party to another":
    await party1.send(party2, 42)

  asynctest "can receive values for other party":
    await party1.send(party2, 42)
    check (await party2.receive(party1)) == 42

  asynctest "value is received by recipient only":
    await party1.send(party2, 42)
    expect Exception:
      discard waitFor party1.receive(party2)

  asynctest "value is received from specified sender only":
    await party1.send(party1, 42)
    expect Exception:
      discard waitFor party1.receive(party2)

  asynctest "it can broadcast to other parties":
    await party3.broadcast(42)
    check (await party1.receive(party3)) == 42
    check (await party2.receive(party3)) == 42
