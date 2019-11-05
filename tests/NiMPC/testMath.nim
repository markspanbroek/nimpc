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
      computation:
        let sum = party1.share(40) + party1.obtain(party2)
        check (await sum.reveal()) == 42
      computation:
        let sum = party2.obtain(party1) + party2.share(2)
        check (await sum.reveal()) == 42

  test "refuses to add numbers from different parties":
    let a = LocalParty().random()
    let b = LocalParty().random()
    expect Exception:
      discard a + b

  asynctest "adds a constant":
    twoParties:
      computation:
        let sum = party1.share(40) + 2
        check (await sum.reveal()) == 42
      computation:
        let sum = party2.obtain(party1) + 2
        check (await sum.reveal()) == 42

  test "subtracts secret numbers":
    twoParties:
      computation:
        let difference = party1.share(44) - party1.obtain(party2)
        check (await difference.reveal()) == 42
      computation:
        let difference = party2.obtain(party1) - party2.share(2)
        check (await difference.reveal()) == 42

  test "refuses to subtract numbers from different parties":
    let a = LocalParty().random()
    let b = LocalParty().random()
    expect Exception:
      discard a - b

  test "subtracts a constant":
    twoParties:
      computation:
        let difference = party1.share(42) - 42
        check (await difference.reveal()) == 0
      computation:
        let difference = party2.obtain(party1) - 42
        check (await difference.reveal()) == 0

  test "multipies by a constant":
    twoParties:
      computation:
        let product = party1.share(21) * 2
        check (await product.reveal()) == 42
      computation:
        let product = 2 * party2.obtain(party1)
        check (await product.reveal()) == 42

  test "multiplies secret numbers":
    threeParties:
      computation:
        let product = party1.share(21) * party1.obtain(party2)
        check (await product.reveal()) == 42
      computation:
        let product = party2.obtain(party1) * party2.share(2)
        check (await product.reveal()) == 42
      computation:
        let product = party3.obtain(party1) * party3.obtain(party2)
        check (await product.reveal()) == 42

  test "refuses to multiply numbers from different parties":
    let a = LocalParty().random()
    let b = LocalParty().random()
    expect Exception:
      discard a * b
