import unittest
import NiMPC/Parties
import NiMPC/SecretSharing
import NiMPC/Random
import NiMPC/Math
import NiMPC/MultipartyComputation

suite "math":
  
  test "adds secret numbers":
    multiparty:
      computation:
        let sum = party.share(40) + party.obtain(parties[1])
        await sum.disclose()
        check (await sum.open()) == 42
      computation:
        let sum = party.obtain(parties[0]) + party.share(2)
        await sum.disclose()
        check (await sum.open()) == 42

  test "refuses to add numbers from different parties":
    let party1, party2 = Party()
    let a = party1.random()
    let b = party2.random()
    expect Exception:
      discard a + b

  test "adds a constant":
    multiparty:
      computation:
        let sum = party.share(40) + 2
        await sum.disclose()
        check (await sum.open()) == 42
      computation:
        let sum = party.obtain(parties[0]) + 2
        await sum.disclose()
        check (await sum.open()) == 42

  test "subtracts secret numbers":
    multiparty:
      computation:
        let difference = party.share(44) - party.obtain(parties[1])
        await difference.disclose()
        check (await difference.open()) == 42
      computation:
        let difference = party.obtain(parties[0]) - party.share(2)
        await difference.disclose()
        check (await difference.open()) == 42

  test "refuses to subtract numbers from different parties":
    let party1, party2 = Party()
    let a = party1.random()
    let b = party2.random()
    expect Exception:
      discard a - b

  test "subtracts a constant":
    multiparty:
      computation:
        let sum = party.share(42) - 42
        await sum.disclose()
        check (await sum.open()) == 0
      computation:
        let sum = 42 - party.obtain(parties[0])
        await sum.disclose()
        check (await sum.open()) == 0

  test "multipies by a constant":
    multiparty:
      computation:
        let product = party.share(21) * 2
        await product.disclose()
        check (await product.open()) == 42
      computation:
        let product = 2 * party.obtain(parties[0])
        await product.disclose()
        check (await product.open()) == 42

  test "multiplies secret numbers":
    multiparty:
      computation:
        let product = party.share(21) * party.obtain(parties[1])
        await product.disclose()
        check (await product.open()) == 42
      computation:        
        let product = party.obtain(parties[0]) * party.share(2)
        await product.disclose()
        check (await product.open()) == 42

  test "refuses to multiply numbers from different parties":
    let party1, party2 = Party()
    let a = party1.random()
    let b = party2.random()
    expect Exception:
      discard a * b
