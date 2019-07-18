import unittest
import asynctest
import parties
import NiMPC

asynctest "adds secret numbers":
  twoParties:
    let sum1 = party1.share(40) + party1.obtain(party2)
    let sum2 = party2.obtain(party1) + party2.share(2)

    await sum1.reveal(party2)
    await sum2.reveal(party1)

    check (await sum1.open()) == 42
    check (await sum2.open()) == 42

asynctest "refuses to add numbers from different parties":
  twoParties:
    let a = party1.random()
    let b = party2.random()
    expect Exception:
      discard await a + b

asynctest "subtracts secret numbers":
  singleParty:
    let difference = party.share(44) - party.share(2)
    check (await difference.open()) == 42
