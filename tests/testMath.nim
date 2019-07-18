import unittest
import asynctest
import parties
import NiMPC

asynctest "adds secret numbers":
  twoParties:
    let a1, b1 = random()
    let c1 = a1 + b1
    await party1.reveal(c1, party2)

    let a2, b2 = random()
    let c2 = a2 + b2
    await party2.reveal(c2, party1)

    check (await party1.open(c1)) == (await party2.open(c2))
