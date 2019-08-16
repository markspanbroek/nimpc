import unittest
import asynctest
import parties
import NiMPC/Parties
import NiMPC/Random
import NiMPC/SecretSharing

suite "secret sharing":

  asynctest "opens a shared random value":
    twoParties:
      let secret1 = party1.random()
      let secret2 = party2.random()
      await secret1.disclose(party2)
      discard await secret2.open()

  asynctest "discloses to all parties":
    threeParties:
      let value1 = party1.share(42)
      let value2 = party2.obtain(party1)
      let value3 = party3.obtain(party1)
      
      await value1.disclose()
      await value2.disclose()
      await value3.disclose()

      check (await value1.open()) == 42
      check (await value2.open()) == 42
      check (await value3.open()) == 42

  asynctest "shares a secret":
    twoParties:
      let secret1 = party1.share(42)
      let secret2 = party2.obtain(party1)
      await secret1.disclose(party2)
      let opened = await secret2.open()
      check opened == 42
