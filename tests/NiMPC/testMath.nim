import unittest
import asynctest
import parties
import NiMPC/Parties
import NiMPC/SecretSharing
import NiMPC/Random
import NiMPC/Math

suite "math":
  
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

  asynctest "adds a constant":
    twoParties:
      let sum1 = party1.share(40) + 2
      let sum2 = 2 + party2.obtain(party1)
      await sum2.reveal()
      await sum1.reveal()
      check (await sum1.open()) == 42
      check (await sum2.open()) == 42

  asynctest "subtracts secret numbers":
    twoParties:
      let difference1 = party1.share(44) - party1.obtain(party2)
      let difference2 = party2.obtain(party1) - party2.share(2)
      await difference1.reveal()
      await difference2.reveal()
      check (await difference1.open()) == 42
      check (await difference2.open()) == 42

  asynctest "refuses to subtract numbers from different parties":
    twoParties:
      let a = party1.random()
      let b = party2.random()
      expect Exception:
        discard await a - b

  asynctest "subtracts a constant":
    twoParties:
      let sum1 = party1.share(42) - 42
      let sum2 = 42 - party2.obtain(party1)
      await sum2.reveal()
      await sum1.reveal()
      check (await sum1.open()) == 0
      check (await sum2.open()) == 0

  asynctest "multipies by a constant":
    twoParties:
      let product1 = party1.share(21) * 2
      let product2 = 2 * party2.obtain(party1)
      await product1.reveal()
      await product2.reveal()
      check (await product1.open()) == 42
      check (await product2.open()) == 42

  asynctest "multiplies secret numbers":
    twoParties:
      let product1 = party1.share(21) * party1.obtain(party2)
      let product2 = party2.obtain(party1) * party2.share(2)

      await product1.reveal(party2)
      await product2.reveal(party1)

      let foo1 = (await product1.open())
      let foo2 = (await product2.open()) 
      check foo1 == 42
      check foo2 == 42

  asynctest "refuses to multiply numbers from different parties":
    twoParties:
      let a = party1.random()
      let b = party2.random()
      expect Exception:
        discard await a * b
