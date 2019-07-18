import unittest
import asynctest
import parties
import NiMPC

asynctest "generates different random numbers":
  singleParty:
    let secret1, secret2 = party.random()
    check (await secret1.open()) != (await secret2.open())

asynctest "opens a shared random value":
  twoParties:
    let secret1 = party1.random()
    let secret2 = party2.random()
    await secret1.reveal(party2)
    discard await secret2.open()

asynctest "reveals to all parties":
  threeParties:
    let value1 = party1.share(42)
    let value2 = party2.obtain(party1)
    let value3 = party3.obtain(party1)
    
    await value1.reveal()
    await value2.reveal()
    await value3.reveal()

    check (await value1.open()) == 42
    check (await value2.open()) == 42
    check (await value3.open()) == 42

asynctest "shares a secret":
  twoParties:
    let secret1 = await party1.share(42)
    let secret2 = await party2.obtain(party1)
    await secret1.reveal(party2)
    let opened = await secret2.open()
    check opened == 42
