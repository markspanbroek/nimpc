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

    await party1.reveal(c1, party2)
    await party2.reveal(c2, party1)

    check (await party1.open(c1)) == 42
    check (await party2.open(c2)) == 42
