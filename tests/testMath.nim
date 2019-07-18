import unittest
import asynctest
import parties
import NiMPC

asynctest "adds secret numbers":
  twoParties:
    let a = await party1.share(40)
    let b = await party2.share(2)

    let c1 = a + await party1.obtain(party2)
    let c2 = b + await party2.obtain(party1)

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
