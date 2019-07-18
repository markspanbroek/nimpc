import unittest
import asynctest
import parties
import NiMPC

asynctest "adds secret numbers":
  twoParties:
    let c1 = party1.share(40) + party1.obtain(party2)
    let c2 = party2.obtain(party1) + party2.share(2)

    await c1.reveal(party2)
    await c2.reveal(party1)

    check (await c1.open()) == 42
    check (await c2.open()) == 42

test "refuses to add numbers from different parties":
  twoParties:
    let a = party1.random()
    let b = party2.random()
    expect Exception:
      discard a + b
