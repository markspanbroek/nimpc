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
        check (await sum.reveal()) == 42
      computation:
        let sum = party.obtain(parties[0]) + party.share(2)
        check (await sum.reveal()) == 42

  test "refuses to add numbers from different parties":
    let a = LocalParty().random()
    let b = LocalParty().random()
    expect Exception:
      discard a + b

  test "adds a constant":
    multiparty:
      computation:
        let sum = party.share(40) + 2
        check (await sum.reveal()) == 42
      computation:
        let sum = party.obtain(parties[0]) + 2
        check (await sum.reveal()) == 42

  test "subtracts secret numbers":
    multiparty:
      computation:
        let difference = party.share(44) - party.obtain(parties[1])
        check (await difference.reveal()) == 42
      computation:
        let difference = party.obtain(parties[0]) - party.share(2)
        check (await difference.reveal()) == 42

  test "refuses to subtract numbers from different parties":
    let a = LocalParty().random()
    let b = LocalParty().random()
    expect Exception:
      discard a - b

  test "subtracts a constant":
    multiparty:
      computation:
        let sum = party.share(42) - 42
        check (await sum.reveal()) == 0
      computation:
        let sum = 42 - party.obtain(parties[0])
        check (await sum.reveal()) == 0

  test "multipies by a constant":
    multiparty:
      computation:
        let product = party.share(21) * 2
        check (await product.reveal()) == 42
      computation:
        let product = 2 * party.obtain(parties[0])
        check (await product.reveal()) == 42

  test "multiplies secret numbers":
    multiparty:
      computation:
        let product = party.share(21) * party.obtain(parties[1])
        check (await product.reveal()) == 42
      computation:
        let product = party.obtain(parties[0]) * party.share(2)
        check (await product.reveal()) == 42
      computation:
        let product = party.obtain(parties[0]) * party.obtain(parties[1])
        check (await product.reveal()) == 42

  test "refuses to multiply numbers from different parties":
    let a = LocalParty().random()
    let b = LocalParty().random()
    expect Exception:
      discard a * b
