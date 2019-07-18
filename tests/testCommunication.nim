import unittest
import bigints
import asynctest
import parties
import NiMPC

asynctest "can send from one party to another":
  twoParties:
    await party1.send(party2, 42)

asynctest "can receive values for other party":
  twoParties:
    await party1.send(party2, 42)
    check (await party2.receive(party1)) == 42

asynctest "value is received by recipient only":
  twoParties:
    await party1.send(party2, 42)
    expect Exception:
      discard waitFor party1.receive(party2)

asynctest "value is received from specified sender only":
  twoParties:
    await party1.send(party1, 42)
    expect Exception:
      discard waitFor party1.receive(party2)

asynctest "it can broadcast to other parties":
  threeParties:
    await party3.broadcast(42)
    check (await party1.receive(party3)) == 42
    check (await party2.receive(party3)) == 42
